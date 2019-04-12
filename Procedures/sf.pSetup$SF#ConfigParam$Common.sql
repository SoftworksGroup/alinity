SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pSetup$SF#ConfigParam$Common]
	@SetupUser nvarchar(75) -- user assigned to audit insert and update audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.ConfigParam data
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Returns common configuration parameter values as a data set for use in parent setup procedure
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)					| Month Year  | Change Summary
				 : ------------------ | ------------|-------------------------------------------------------------------------------------
				 : Tim Edlund					| Dec		2015	| Initial Version
				 : Tim Edlund					| Feb		2017	| Added parms for help desk and policy numbers and help desk email (from product version)
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure simplifies management of common configuration parameters across applications. While each application will typically 
include some configuration parameters not used by any other application, there are also many common parameters that all 
applications use.  Many of these are used by the framework itself.  For example: "MaxRowsOnSearch" (applied in search 
procedures), and "ProgramErrorSuffix"/"ConfigErrorSuffix" (error messaging) are used by all applications.

This procedure is named as a sub-routine because it should only be called in that context.  The parent procedure will exist
in the product project (not the framework) and should be named: dbo.pSetup$SF#ConfigParam.  This subroutine should be called 
near the top of the logic to return records into a memory table.  The structure of the memory table must match the structure
shown in this procedure!  The typical syntax used appears below:

		-- call the sproc to insert/update the common configuration values
		-- used by the framework

		insert 
			@setup
		(
			 ConfigParamSCD		
			,ConfigParamName	
			,ParamValue				
			,DefaultParamValue
			,DataType					
			,MaxLength				
			,IsReadOnly				
			,UsageNotes				
		)
		exec sf.pSetup$SF#ConfigParam$Common
			 @SetupUser	= @SetupUser
			,@Language  = @Language
			,@Region    = @Region


After the values are passed into the caller's memory table any overrides required to change default settings can be applied to 
the "DefaultParamValue" column through update statements. If necessary documentation can also be over-written with a product 
specific version, however, that should not generally be required.  

Replacement values
------------------
For some parameters placeholder values are inserted in the value and documentation columns to support replacements made in the 
parent procedure.  For example, references to the help desk and system user include a domain token: 

e.g.  system@{SYSTEMUSER}"								->	system@clientorg.com				default user ID for batch processes
			http://support.{PRODUCT}.com				->	http://support.synoptec.com	product name for help desk reference

Note that the "SystemUser" token is replaced by THIS procedure with the @SetupUser passed in.

If the @Region parameter is passed as "Synoptec" or "Permitsy" (recognized product names), then the {PRODUCT} placeholder is
replaced with @Region value.  The {SYSTEMUSER} token is replaced with the @SetupUser value.  Other tokens must be replaced 
by the caller based on product requirements. All tokens must be replaced via an update statement in the parent procedure to complete 
the configuration.  See code - search for "{" - to check for all replacement tokens.

Consider Language setting
-------------------------
As of this writing the procedure only supports returning configuration values in English.  Be sure to avoid overwriting
translated parameter documentation!

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures common configuration values are inserted or updated.">		
	<SQLScript>
		<![CDATA[
		
			exec sf.pSetup$SF#ConfigParam$Common
				 @SetupUser = 'system@synoptec.com'
				,@Language	= 'en'
				,@Region		= 'Synoptec'

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pSetup$SF#ConfigParam$Common'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON					 bit					 = cast(1 as bit) -- constant to repeated prevent type conversions
	 ,@OFF				 bit					 = cast(0 as bit) -- constant to repeated prevent type conversions
	 ,@utcOffset	 char(6);												-- default offset - taken from time at the db server

	declare @setup table
	(
		ID								int						identity(1, 1)
	 ,ConfigParamSCD		varchar(25)		not null
	 ,ConfigParamName		nvarchar(50)	not null
	 ,ParamValue				nvarchar(max) null
	 ,DefaultParamValue nvarchar(max) not null
	 ,DataType					varchar(15)		not null
	 ,MaxLength					int						null
	 ,IsReadOnly				bit						not null
	 ,UsageNotes				nvarchar(max) null
	);

	begin try

		set @utcOffset = cast(datename(tz, sysdatetimeoffset()) as char(6)); -- server timezone offset is the default

		insert
			@setup
		(
			ConfigParamSCD
		 ,ConfigParamName
		 ,DefaultParamValue
		 ,DataType
		 ,MaxLength
		 ,IsReadOnly
		 ,UsageNotes
		)
		values
		(
			'DBModelNo', N'Database model version', convert(varchar(8), sysdatetime(), 112), 'varchar', 8, @ON
		 ,N'This value identifies when the last set of model updates were applied to the database. The value is useful for '
			+ 'debugging issues when working with the help desk and also for applying the correct set of change scripts for ' + 'upgrades.'
		)
		 ,(
				'DatabaseStatusColor', N'Database status color', '#FF0a3e5a', 'varchar', 9, @ON
			 ,N'This value is set by the application batch validation of data is performed.  If any errors are detected, the database icon '
				+ 'presented in the user interface is set to a red color. Otherwise the icon appears in a non-highlighted color matching the '
				+ 'rest of the screen design.  Note that the icon color is set automatically when batch validation is run and cannot be set '
				+ 'manually through configuration.'
			)
		 ,(
				'ClientTimeZoneOffset', N'Timezone offset from GMT', @utcOffset, 'varchar', 6, @OFF
			 ,N'This value is used to convert time values set at the database server with times provided by the end user. This option '
				+ 'is important where the database server and client workstations are not in the same time zone. The value must be entered '
				+ 'using a number of hours from the Universal Time Code/Greenwich Mean Time.  For example, Mountain Standard Time is "-06:00" '
				+ 'from UTC/GMT (and -07:00 during the daylight savings period).'
			)
		 ,(
				'DSTStatus', N'Daylight Savings Time', (case when sf.fDST#IsActive() = @ON then 'ACTIVE' else 'INACTIVE' end), 'varchar', 10, @OFF
			 ,N'This value is used to record whether the adjustment for day-light-savings time is currently active (ACTIVE) or not (INACTIVE), or, whether '
				+ 'DST is not applied (N/A).  Changes to this value where DST is observed are managed automatically by the application. A process sets '
				+ 'the value to "ON" each March and "OFF" each November.  Changing the value to "N/A" will stop adjustments to your time zone offset '
				+ 'for DST.'
			)
		 ,(
				'SystemUser', N'System user', N'{SYSTEMUSER}', 'nvarchar', 75, @ON
			 ,N'This value is applied to standard auditing columns ("created by", "updated by") when changes are made to the database '
				+ 'by automated batch processes such as importing data from external sources. The value is not a licensed user account '
				+ 'and cannot be used to login.'
			)
		 ,(
				'AdministratorEmail', N'Administrator email', N'Admin@?.com', 'nvarchar', 150, @ON
			 ,N'This value is used to store the email address of the system administrator. This is not the address of the products''s '
				+ 'help desk but rather for end users to send requests to related to program administration and policy questions.  For '
				+ 'example, to request a change in user rights granted, or to make a name change if such changes cannot be made directly '
				+ 'by end users in the application. It is best practice to use a group email address rather than an individual email so '
				+ 'that personnel changes do not require that the value be updated.'
			)
		 ,(
				'SenderEmail', N'Sending email', N'Sender@{PRODUCT}.com', 'nvarchar', 150, @ON
			 ,N'This is the email address used by the system to send email to users and administrators. The email address must be'
				+ 'valid and verified to use the distribution method is configured in email setup:  Amazon SES or SMTP. The account'
				+ 'need not accept replies.  End users see this address when reading mail messages sent by the application.  If a'
				+ 'different reply-to address is not specified in email setup, this will be the reply address by default.'
			)
		 ,(
				'ProgramErrorSuffix', N'Program error suffix'
			 ,N'Please try again. If the problem persists please contact our help desk at http://support.{PRODUCT}.com or your system '
				+ 'administrator for assistance.', 'nvarchar', 250, @OFF
			 ,N'This value is appended onto messages where an unexpected error has occurred in the program but the application is '
				+ 'able to recover and keep running. The text should advise the user what to do in this scenario. Normally this will '
				+ 'include retrying the process and contacting the help desk if the error persists. While product help desk '
				+ 'support is generally provided to licensed administrators only, program errors can be reported by any user.  The '
				+ 'option to report the problem with the local administrator may also be helpful. Note that a separate suffix is '
				+ 'available for "configuration" errors.'
			)
		 ,(
				'ConfigErrorSuffix', N'Configuration error suffix'
			 ,N'Please update your configuration. If you are a licensed administrator and need help with configuration, please contact '
				+ 'our help desk at http://support.{PRODUCT}.com, otherwise please contact your local administrator.', 'nvarchar', 250, @OFF
			 ,N'This value is appended onto error messages where the source of the error appears to be configuration settings or '
				+ 'missing setup values. The text should advise the user what to do in this scenario. Normally this will '
				+ 'include updating the configuration or contacting the help desk if assistance is required. Since product help '
				+ 'desk support is only provided to licensed administrators, it may be appropriate to include an email address and phone '
				+ 'number for the local administrator. Note that a separate suffix is available for "program" errors.'
			)
		 ,(
				'TenantReservationHours', N'Tenant reservation hours', N'24', 'int', 3, @OFF
			 ,N'This value controls how long (in hours) a pending trial request will wait for confirmation by the user.  During this '
				+ 'period no other potential tenants can attempt to reserve the same sub-domain, tenant name etc. so that duplication is ' + 'avoided.'
			)
		 ,(
				'InviteReservationHours', N'Invite reservation in hours', N'2', 'int', 3, @OFF
			 ,N'This value is used to identify when a invitation expires. When a user signs up through the website they receive '
				+ 'an email asking them to confirm their account. After the invitation is sent, the email address is reserved as a unique '
				+ 'user name which no else can try to register while it is reserved. This value controls how long the email address is '
				+ 'reserved for. The setting is in hours.'
			)
		 ,(
				'MaxRowsOnSearch', N'Maximum search results', N'100', 'smallint', null, @OFF
			 ,N'This value controls the maximum number of records the application will return when a search is executed.  Limiting '
				+ 'search results is good practice to help protect the database against inappropriate use such as scanning of personal '
				+ 'information or fishing. The parameter is also important for use of the application on mobile devices where large '
				+ 'data sets may be slow to transmit over wireless services.  End users should generally have specific search criteria '
				+ 'such as names, identification numbers, etc. for locating records to avoid the need to browse large result sets. '
				+ 'Limiting search results to about 100 records works well in most configurations. '
			)
		 ,(
				'MaxRowsForAutoSearch', N'Maximum records for automatic search', N'20', 'smallint', null, @OFF
			 ,N'This value controls whether the application will immediately return all the records using a default search when the '
				+ 'the user opens search pages.  Normally search criteria must be entered by the user before any records are displayed, '
				+ 'however for screens with only a small number of records (less than or equal to this value), automatically returning '
				+ 'all of them to display for the user to select from may be more convenient than searching for specific records.  This '
				+ 'value sets a limit after which search criteria must be entered by the user before any records are returned to the ' + 'display'
			)
		 ,(
				'TimeOut', N'Inactivity timeout', N'20', 'int', 3, @OFF
			 ,N'The maximum number of minutes the application should be allowed to remain idle for external users before requiring another login.'
				+ 'This is a security parameter that requires that the user to login again after the set period of inactivity. '
				+ 'This prevents users from leaving logged workstations accessible for long periods of time to passers-by. Note that '
				+ 'inactive time is measured as the gap between database accesses. Simple mouse movement is not sufficient to restart ' + 'the idle-time clock.'
			)
		 ,(
				'AdminTimeOut', N'Admin inactivity timeout', N'20', 'int', 3, @OFF
			 ,N'The maximum number of minutes the application should be allowed to remain idle for administrators before requiring another login.'
				+ 'This is a security parameter that requires that the user to login again after the set period of inactivity. '
				+ 'This prevents users from leaving logged workstations accessible for long periods of time to passers-by. Note that '
				+ 'inactive time is measured as the gap between database accesses. Simple mouse movement is not sufficient to restart ' + 'the idle-time clock.'
			)
		 ,(
				'RecentAccessHours', N'Recent access threshold (hours)', N'24', 'smallint', null, @OFF
			 ,N'This value established the threshold the application uses for "Recently Accessed" searches.  Many screens in the '
				+ 'application provide a quick search where the application returns a list of records that have been recently accessed '
				+ 'by the user.  The definition of "recent" is defined using this parameter in units of hours.  The default value is 24 '
				+ 'hours; meaning that any record where details have been retrieved by that user within the last 24 hours will be '
				+ 'included in "recently accessed" search results. Note that, by default, weekends are not included in the 24 period but '
				+ 'this can be controlled using the "Exclude Weekends for Recent Access" configuration option.'
			)
		 ,(
				'ExcludeWeekendsForRecent', N'Exclude weekends for recent access', N'1', 'bit', 1, @OFF
			 ,N'This value controls whether Saturday and Sunday will be excluded when calculating whether a record has been "recently '
				+ 'accessed" according to hour limit put into the Recent-Access-Threshold. For example, if the threshold is set at 24 hours '
				+ 'and this parameter is turned on (1), then a record accessed Friday afternoon will still be considered to be recently '
				+ 'accessed the following Monday morning.  Note that this configuration value is always treated as OFF (0) if the recent '
				+ 'hours access threshold is set to any value greater than 120 hours.'
			)
		 ,(
				'FutureDatingLimit', N'Future date limit', N'30', 'int', 3, @OFF
			 ,N'This value controls how far into the future (in units of DAYS) a transaction, including security and other forms of record '
				+ 'assignments, can be dated.  Allowing some future dating is convenient where there is a need to setup a record to apply '
				+ 'automatically in the future (for example setting up grants on a user record to take effect next month). Setting a limit '
				+ 'on the extent of future dating helps prevent data entry errors.'
			)
		 ,(
				'BackDatingLimit', N'Back date limit', N'0', 'int', 3, @OFF
			 ,N'This value controls how far into the past (in units of DAYS) a transaction, including security and other forms of record '
				+ 'assignments, can be dated. In general back dating should be avoided, however, it may be required during conversion and start-up '
				+ 'to load historical data.  In other situations it may be necessary to allow prior-day entries to be dated correctly. Always keep '
				+ 'backdating intervals allowed as short as possible.  Back dating business rules can be turned off on selected tables during system '
				+ 'conversion using the Business Rules Management screen.'
			)
		 ,(
				'ValidEmailDomains', N'Valid email domains', N'*', 'varchar', 50, @OFF
			 ,N'This value defines the list of email domains that will be considered valid by the application. This is a comma '
				+ 'delimited list: e.g. ".com, .ca, .edu" (no quotes).  If a domain is entered on an email address that is not in the '
				+ 'list, and that business rule is enabled, then an error is raised and the email address cannot be saved. The purpose '
				+ 'of this value is to improve accuracy and reliability of email addresses managed in the application. To allow email '
				+ 'addresses from any domain, either turn the business rule off in the configuration or set this value to "*" (no quotes).'
			)
		 ,(
				'UserProfileReviewMonths', N'User account review frequency', N'12', 'int', 2, @OFF
			 ,N'This value is used to identify User Accounts that require review.  User Accounts should be reviewed periodically '
				+ 'to ensure they are still required and that access provided to the user remains appropriate.  The target interval '
				+ 'between reviews is specified in months .  When an account has not been reviewed within the period defined, an icon '
				+ 'appears to mark the record overdue and these accounts can also be accessed through a built-in query.'
			)
		 ,(
				'UnusedAccountWarningDays', N'Unused account warning', N'90', 'int', 3, @OFF
			 ,N'The maximum number of days a user account can go without logging in, before it is identified for follow-up as a possible '
				+ 'unused account.  A built-in task trigger (enabled by default) creates follow-up tasks for accounts that have been unused '
				+ 'for this number of days.  Removing unused accounts from the system is a security best-practice.'
			)
		 ,(
				'JobHistoryRetentionMonths', N'Job history retention (months)', N'1', 'int', 1, @OFF
			 ,N'The maximum number of months the history of background jobs should be retained. One (1) month is recommended and 3 months is the maximum.'
			)
		 ,(
				'HelpdeskEmail', N'Help desk email', N'support@softworksgroup.com', 'nvarchar', 75, @ON
			 ,N'This is the email address for submitting tickets to the Help Desk. When a program error is encountered, details are '
				+ 'automatically captured by the software and the user is given the option to send them to the help desk. This is the ' + 'email address used.'
			)
		 ,(
				'TechnicalHelpDeskNumber', N'Technical help desk number', N'1-800-755-1546', 'nvarchar', 50, @OFF
			 ,N'The technical help desk number is displayed in the application to give users a number to call when they have technical issues.'
			)
		 ,(
				'PolicyHelpDeskNumber', N'Policy help desk number', N'000-000-0000', 'nvarchar', 50, @OFF
			 ,N'The policy help desk number is displayed in the application to give users a number to call when they have policy issues.'
			)
			,(
				'MaxExportTotalMB', N'Maximum total export file size MB', N'500', 'int', 2, @ON
			 ,N'The maximum total size allowed for this installation for all export files in MB.'
			);

		-- if the region includes a recognized product name,
		-- run the replacement

		if @Region = 'Synoptec' or @Region = 'Alinity'
		begin

			update
				@setup
			set
				DefaultParamValue = replace(DefaultParamValue, '{PRODUCT}', lower(@Region))
			 ,UsageNotes = replace(UsageNotes, '{PRODUCT}', @Region);

		end;

		-- replace system user token with setup user value 

		update
			@setup
		set
			DefaultParamValue = replace(DefaultParamValue, '{SYSTEMUSER}', @SetupUser);

		-- replace alinity domain with alinityapp

		update
			@setup
		set
			DefaultParamValue = replace(DefaultParamValue, 'alinity.com', 'alinityapp.com')
		where
			DefaultParamValue like N'%alinity.com%';

		-- finally output result to the caller

		select
			s.ConfigParamSCD
		 ,s.ConfigParamName
		 ,s.ParamValue
		 ,s.DefaultParamValue
		 ,s.DataType
		 ,s.MaxLength
		 ,s.IsReadOnly
		 ,s.UsageNotes
		from
			@setup s
		order by
			s.ID;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
