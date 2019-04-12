SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$Country]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.Country data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates dbo.Country master table with a complete country list
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Apr 2017			| Initial Version (re-write)
				 : Tim Edlund		| Jul 2018			| Added logic to ensure default record exists
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure is responsible for creating the initial data set in the dbo.Country table and for updating it with missing 
countries. The product works best when a full country list is included in the master table.  This procedure provides the list
including associated ISO coding and abbreviations.   Only missing country codes are added.  The routine avoids duplicates
by checking for the existing country using both the CountryName and ISOA3 values.

The procedure also checks for the existence of a default country (frequently required for addressing procedures). If none is
found, the system sets the default to CANADA.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[

			if	not exists (select 1 from dbo.StateProvince)
			begin
				delete from dbo.Country
				dbcc checkident( 'dbo.Country', reseed, 1000000) with NO_INFOMSGS
			end
		
			exec dbo.pSetup$Country
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.Country order by CreateTime desc

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$Country'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo						int						= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON									bit						= cast(1 as bit)	-- constant for bit = 1
	 ,@OFF								bit						= cast(0 as bit)	-- constant for bit = 0
	 ,@sourceCount				int															-- count of rows in the source table
	 ,@targetCount				int															-- count of rows in the target table
	 ,@defaultCountryName nvarchar(50);										-- current default in the table (if any)

	declare @sample table -- work table to store full sample data set
	(
		ID					int					 identity(1, 1)
	 ,CountryName nvarchar(50) not null
	 ,ISOA2				char(2)			 not null
	 ,ISOA3				char(3)			 not null
	 ,ISONumber		smallint		 not null
	 ,IsDefault		bit					 not null default cast(0 as bit)
	);

	begin try

		insert -- load memory table to compare with the target table
			@sample (CountryName, ISONumber, ISOA2, ISOA3)
		values -- values are sorted alphabetically
		(N'Canada', 124, 'CA', 'CAN') -- set as default if no other default is set (see below)
		 ,(N'Afghanistan', 4, 'AF', 'AFG')
		 ,(N'Albania', 8, 'AL', 'ALB')
		 ,(N'Algeria', 12, 'DZ', 'DZA')
		 ,(N'American Samoa', 16, 'AS', 'ASM')
		 ,(N'Andorra', 20, 'AD', 'AND')
		 ,(N'Angola', 24, 'AO', 'AGO')
		 ,(N'Anguilla', 660, 'AI', 'AIA')
		 ,(N'Antigua & Barbuda', 28, 'AG', 'ATG')
		 ,(N'Argentina', 32, 'AR', 'ARG')
		 ,(N'Armenia', 51, 'AM', 'ARM')
		 ,(N'Aruba', 533, 'AW', 'ABW')
		 ,(N'Australia', 36, 'AU', 'AUS')
		 ,(N'Austria', 40, 'AT', 'AUT')
		 ,(N'Azerbaijan', 31, 'AZ', 'AZE')
		 ,(N'Bahamas', 44, 'BS', 'BHS')
		 ,(N'Bahrain', 48, 'BH', 'BHR')
		 ,(N'Bangladesh', 50, 'BD', 'BGD')
		 ,(N'Barbados', 52, 'BB', 'BRB')
		 ,(N'Belarus', 112, 'BY', 'BLR')
		 ,(N'Belgium', 56, 'BE', 'BEL')
		 ,(N'Belize', 84, 'BZ', 'BLZ')
		 ,(N'Benin', 204, 'BJ', 'BEN')
		 ,(N'Bermuda', 60, 'BM', 'BMU')
		 ,(N'Bhutan', 64, 'BT', 'BTN')
		 ,(N'Bolivia', 68, 'BO', 'BOL')
		 ,(N'Bonaire', 535, 'BQ', 'BES')
		 ,(N'Bosnia-Herzegovina', 70, 'BA', 'BIH')
		 ,(N'Botswana', 72, 'BW', 'BWA')
		 ,(N'Brazil', 76, 'BR', 'BRA')
		 ,(N'British Indian Ocean Territory', 86, 'IO', 'IOT')
		 ,(N'British Virgin Islands', 92, 'VG', 'VGB')
		 ,(N'Brunei Darussalam', 96, 'BN', 'BRN')
		 ,(N'Bulgaria', 100, 'BG', 'BGR')
		 ,(N'Burkina Faso', 854, 'BF', 'BFA')
		 ,(N'Burundi', 108, 'BI', 'BDI')
		 ,(N'Cambodia', 116, 'KH', 'KHM')
		 ,(N'Cameroon', 120, 'CM', 'CMR')
		 ,(N'Cape Verde Islands', 132, 'CV', 'CPV')
		 ,(N'Cayman Islands', 136, 'KY', 'CYM')
		 ,(N'Central African Republic', 140, 'CF', 'CAF')
		 ,(N'Chad', 148, 'TD', 'TCD')
		 ,(N'Chile', 152, 'CL', 'CHL')
		 ,(N'China', 156, 'CN', 'CHN')
		 ,(N'Christmas Island', 162, 'CX', 'CXR')
		 ,(N'Cocos Islands', 166, 'CC', 'CCK')
		 ,(N'Colombia', 170, 'CO', 'COL')
		 ,(N'Comoros', 174, 'KM', 'COM')
		 ,(N'Congo (Brazzaville)', 178, 'CG', 'COG')
		 ,(N'Congo (Kinshasa)', 180, 'CD', 'ZAR')
		 ,(N'Cook Islands', 184, 'CK', 'COK')
		 ,(N'Costa Rica', 188, 'CR', 'CRI')
		 ,(N'Croatia', 191, 'HR', 'HRV')
		 ,(N'Cuba', 192, 'CU', 'CUB')
		 ,(N'Curaçao', 531, 'CW', 'CUW')
		 ,(N'Cyprus', 196, 'CY', 'CYP')
		 ,(N'Czech Republic', 203, 'CZ', 'CZE')
		 ,(N'Denmark', 208, 'DK', 'DNK')
		 ,(N'Djibouti', 262, 'DJ', 'DJI')
		 ,(N'Dominica', 212, 'DM', 'DMA')
		 ,(N'Dominican Republic', 214, 'DO', 'DOM')
		 ,(N'East Timor', 626, 'TL', 'TLS')
		 ,(N'Ecuador', 218, 'EC', 'ECU')
		 ,(N'Egypt', 818, 'EG', 'EGY')
		 ,(N'El Salvador', 222, 'SV', 'SLV')
		 ,(N'Equatorial Guinea', 226, 'GQ', 'GNQ')
		 ,(N'Eritrea', 232, 'ER', 'ERI')
		 ,(N'Estonia', 233, 'EE', 'EST')
		 ,(N'Ethiopia', 231, 'ET', 'ETH')
		 ,(N'Faeroe Islands', 234, 'FO', 'FRO')
		 ,(N'Falkland Islands', 238, 'FK', 'FLK')
		 ,(N'Fiji', 242, 'FJ', 'FJI')
		 ,(N'Finland', 246, 'FI', 'FIN')
		 ,(N'France', 250, 'FR', 'FRA')
		 ,(N'French Guiana', 254, 'GF', 'GUF')
		 ,(N'French Polynesia', 258, 'PF', 'PYF')
		 ,(N'French Southern Territories', 260, 'TF', 'ATF')
		 ,(N'Gabon', 266, 'GA', 'GAB')
		 ,(N'Gambia', 270, 'GM', 'GMB')
		 ,(N'Georgia', 268, 'GE', 'GEO')
		 ,(N'Germany', 276, 'DE', 'DEU')
		 ,(N'Ghana', 288, 'GH', 'GHA')
		 ,(N'Gibralter', 292, 'GI', 'GIB')
		 ,(N'Greece', 300, 'GR', 'GRC')
		 ,(N'Greenland', 304, 'GL', 'GRL')
		 ,(N'Grenada', 308, 'GD', 'GRD')
		 ,(N'Guadeloupe', 312, 'GP', 'GLP')
		 ,(N'Guam', 316, 'GU', 'GUM')
		 ,(N'Guatemala', 320, 'GT', 'GTM')
		 ,(N'Guernsey', 831, 'GG', 'GGY')
		 ,(N'Guinea', 324, 'GN', 'GIN')
		 ,(N'Guinea-Bissau', 624, 'GW', 'GNB')
		 ,(N'Guyana', 328, 'GY', 'GUY')
		 ,(N'Haiti', 332, 'HT', 'HTI')
		 ,(N'Holy See', 336, 'VA', 'VAT')
		 ,(N'Honduras', 340, 'HN', 'HND')
		 ,(N'Hong Kong', 344, 'HK', 'HKG')
		 ,(N'Hungary', 348, 'HU', 'HUN')
		 ,(N'Iceland', 352, 'IS', 'ISL')
		 ,(N'India', 356, 'IN', 'IND')
		 ,(N'Indonesia', 360, 'ID', 'IDN')
		 ,(N'Iran', 364, 'IR', 'IRN')
		 ,(N'Iraq', 368, 'IQ', 'IRQ')
		 ,(N'Ireland', 372, 'IE', 'IRL')
		 ,(N'Isle of Man', 833, 'IM', 'IMN')
		 ,(N'Israel', 376, 'IL', 'ISR')
		 ,(N'Italy', 380, 'IT', 'ITA')
		 ,(N'Ivory Coast', 384, 'CI', 'CIV')
		 ,(N'Jamaica', 388, 'JM', 'JAM')
		 ,(N'Japan', 392, 'JP', 'JPN')
		 ,(N'Jersey', 832, 'JE', 'JEY')
		 ,(N'Jordan', 400, 'JO', 'JOR')
		 ,(N'Kazakhstan', 398, 'KZ', 'KAZ')
		 ,(N'Kenya', 404, 'KE', 'KEN')
		 ,(N'Kiribati', 296, 'KI', 'KIR')
		 ,(N'Kuwait', 414, 'KW', 'KWT')
		 ,(N'Kyrgyzstan', 417, 'KG', 'KGZ')
		 ,(N'Laos', 418, 'LA', 'LAO')
		 ,(N'Latvia', 428, 'LV', 'LVA')
		 ,(N'Lebanon', 422, 'LB', 'LBN')
		 ,(N'Lesotho', 426, 'LS', 'LSO')
		 ,(N'Liberia', 430, 'LR', 'LBR')
		 ,(N'Libya', 434, 'LY', 'LBY')
		 ,(N'Liechtenstein', 438, 'LI', 'LIE')
		 ,(N'Lithuania', 440, 'LT', 'LTU')
		 ,(N'Luxembourg', 442, 'LU', 'LUX')
		 ,(N'Macau', 446, 'MO', 'MAC')
		 ,(N'Macedonia', 807, 'MK', 'MKD')
		 ,(N'Madagascar', 450, 'MG', 'MDG')
		 ,(N'Malawi', 454, 'MW', 'MWI')
		 ,(N'Malaysia', 458, 'MY', 'MYS')
		 ,(N'Maldives', 462, 'MV', 'MDV')
		 ,(N'Mali', 466, 'ML', 'MLI')
		 ,(N'Malta', 470, 'MT', 'MLT')
		 ,(N'Marshall Islands', 584, 'MH', 'MHL')
		 ,(N'Martinique', 474, 'MQ', 'MTQ')
		 ,(N'Mauritania', 478, 'MR', 'MRT')
		 ,(N'Mauritius', 480, 'MU', 'MUS')
		 ,(N'Mayotte', 175, 'YT', 'MYT')
		 ,(N'Mexico', 484, 'MX', 'MEX')
		 ,(N'Micronesia', 583, 'FM', 'FSM')
		 ,(N'Moldova', 498, 'MD', 'MDA')
		 ,(N'Monaco', 492, 'MC', 'MCO')
		 ,(N'Mongolia', 496, 'MN', 'MNG')
		 ,(N'Montenegro', 499, 'ME', 'MNE')
		 ,(N'Montserrat', 500, 'MS', 'MSR')
		 ,(N'Morocco', 504, 'MA', 'MAR')
		 ,(N'Mozambique', 508, 'MZ', 'MOZ')
		 ,(N'Myanmar', 104, 'MM', 'MMR')
		 ,(N'Namibia', 516, 'NA', 'NAM')
		 ,(N'Nauru', 520, 'NR', 'NRU')
		 ,(N'Nepal', 524, 'NP', 'NPL')
		 ,(N'Netherlands', 528, 'NL', 'NLD')
		 ,(N'Netherlands Antilles', 530, 'AN', 'ANT')
		 ,(N'New Caledonia', 540, 'NC', 'NCL')
		 ,(N'New Zealand', 554, 'NZ', 'NZL')
		 ,(N'Nicaragua', 558, 'NI', 'NIC')
		 ,(N'Niger', 562, 'NE', 'NER')
		 ,(N'Nigeria', 566, 'NG', 'NGA')
		 ,(N'Niue', 570, 'NU', 'NIU')
		 ,(N'Norfolk Island', 574, 'NF', 'NFK')
		 ,(N'North Korea', 408, 'KP', 'PRK')
		 ,(N'Northern Mariana Islands', 580, 'MP', 'MNP')
		 ,(N'Norway', 578, 'NO', 'NOR')
		 ,(N'Oman', 512, 'OM', 'OMN')
		 ,(N'Pakistan', 586, 'PK', 'PAK')
		 ,(N'Palau', 585, 'PW', 'PLW')
		 ,(N'Palestinian Territories', 275, 'PS', 'PSE')
		 ,(N'Panama', 591, 'PA', 'PAN')
		 ,(N'Papua New Guinea', 598, 'PG', 'PNG')
		 ,(N'Paraguay', 600, 'PY', 'PRY')
		 ,(N'Peru', 604, 'PE', 'PER')
		 ,(N'Philippines', 608, 'PH', 'PHL')
		 ,(N'Pitcairn Islands', 612, 'PN', 'PCN')
		 ,(N'Poland', 616, 'PL', 'POL')
		 ,(N'Portugal', 620, 'PT', 'PRT')
		 ,(N'Puerto Rico', 630, 'PR', 'PRI')
		 ,(N'Qatar', 634, 'QA', 'QAT')
		 ,(N'Réunion', 638, 'RE', 'REU')
		 ,(N'Romania', 642, 'RO', 'ROU')
		 ,(N'Russia', 643, 'RU', 'RUS')
		 ,(N'Rwanda', 646, 'RW', 'RWA')
		 ,(N'Saba', 535, 'BQ', 'BES')
		 ,(N'Saint Barthelemy', 652, 'BL', 'BLM')
		 ,(N'Saint Christopher & Nevis', 659, 'KN', 'KNA')
		 ,(N'Saint Helena', 654, 'SH', 'SHN')
		 ,(N'Saint Lucia', 662, 'LC', 'LCA')
		 ,(N'Saint Martin', 663, 'MF', 'MAF')
		 ,(N'Saint Pierre & Miquelon', 666, 'PM', 'SPM')
		 ,(N'Saint Vincent & The Grenadines', 670, 'VC', 'VCT')
		 ,(N'Samoa', 882, 'WS', 'WSM')
		 ,(N'San Marino', 674, 'SM', 'SMR')
		 ,(N'Sao Tome & Principe', 678, 'ST', 'STP')
		 ,(N'Saudi Arabia', 682, 'SA', 'SAU')
		 ,(N'Senegal', 686, 'SN', 'SEN')
		 ,(N'Serbia', 688, 'RS', 'SRB')
		 ,(N'Seychelles', 690, 'SC', 'SYC')
		 ,(N'Sierra Leone', 694, 'SL', 'SLE')
		 ,(N'Singapore', 702, 'SG', 'SGP')
		 ,(N'Sint Eustatius', 535, 'BQ', 'BES')
		 ,(N'Sint Maarten', 534, 'SX', 'SXM')
		 ,(N'Slovakia', 703, 'SK', 'SVK')
		 ,(N'Slovenia', 705, 'SI', 'SVN')
		 ,(N'Solomon Islands', 90, 'SB', 'SLB')
		 ,(N'Somalia', 706, 'SO', 'SOM')
		 ,(N'Somaliland', 706, 'SO', 'SOM')
		 ,(N'South Africa', 710, 'ZA', 'ZAF')
		 ,(N'South Georgia & The South Sandwich Islands', 239, 'GS', 'SGS')
		 ,(N'South Korea', 418, 'KR', 'KOR')
		 ,(N'Spain', 724, 'ES', 'ESP')
		 ,(N'Sri Lanka', 144, 'LK', 'LKA')
		 ,(N'Sudan', 736, 'SD', 'SDN')
		 ,(N'Suriname', 740, 'SR', 'SUR')
		 ,(N'Swaziland', 748, 'SZ', 'SWZ')
		 ,(N'Sweden', 752, 'SE', 'SWE')
		 ,(N'Switzerland', 756, 'CH', 'CHE')
		 ,(N'Syria', 760, 'SY', 'SYR')
		 ,(N'Taiwan', 158, 'TW', 'TWN')
		 ,(N'Tajikistan', 762, 'TJ', 'TJK')
		 ,(N'Tanzania', 834, 'TZ', 'TZA')
		 ,(N'Thailand', 764, 'TH', 'THA')
		 ,(N'Togo', 768, 'TG', 'TGO')
		 ,(N'Tokelau', 772, 'TK', 'TKL')
		 ,(N'Tonga', 776, 'TO', 'TON')
		 ,(N'Trinidad & Tobago', 780, 'TT', 'TTO')
		 ,(N'Tunisia', 788, 'TN', 'TUN')
		 ,(N'Turkey', 792, 'TR', 'TUR')
		 ,(N'Turkmenistan', 795, 'TM', 'TKM')
		 ,(N'Turks & Caicos Islands', 796, 'TC', 'TCA')
		 ,(N'Tuvalu', 798, 'TV', 'TUV')
		 ,(N'Uganda', 800, 'UG', 'UGA')
		 ,(N'Ukraine', 804, 'UA', 'UKR')
		 ,(N'United Arab Emirates', 784, 'AE', 'ARE')
		 ,(N'United Kingdom', 826, 'GB', 'GBR')
		 ,(N'United States', 840, 'US', 'USA')
		 ,(N'United States Virgin Islands', 850, 'VI', 'VIR')
		 ,(N'Uruguay', 858, 'UY', 'URY')
		 ,(N'Uzbekistan', 860, 'UZ', 'UZB')
		 ,(N'Vanuatu', 548, 'VU', 'VUT')
		 ,(N'Venezuela', 862, 'VE', 'VEN')
		 ,(N'Vietnam', 704, 'VN', 'VNM')
		 ,(N'Wallis & Futuna', 876, 'WF', 'WLF')
		 ,(N'Western Sahara', 732, 'EH', 'ESH')
		 ,(N'Yemen', 887, 'YE', 'YEM')
		 ,(N'Zambia', 894, 'ZM', 'ZMB')
		 ,(N'Zimbabwe', 716, 'ZW', 'ZWE');

		-- ensure default is established

		select
			@defaultCountryName = x.CountryName
		from
			dbo.Country x
		where
			x.IsDefault = @ON and x.IsActive = @ON;

		if @defaultCountryName is null
		begin
			set @defaultCountryName = N'Canada';
		end;

		update @sample set IsDefault = @ON where CountryName = @defaultCountryName ;

		if not exists (select 1 from dbo .Country c) and not exists (select 1 from dbo .Country c where c.IsDefault = @ON)
		begin
			update dbo .Country set IsDefault = @ON where CountryName = @defaultCountryName;
		end;

		insert
			dbo.Country
		(
			CountryName
		 ,ISONumber
		 ,ISOA2
		 ,ISOA3
		 ,IsDefault
		 ,IsStateProvinceRequired
		 ,CreateUser
		 ,UpdateUser
		)
		select
			x.CountryName
		 ,x.ISONumber
		 ,x.ISOA2
		 ,x.ISOA3
		 ,x.IsDefault
		 ,@OFF
		 ,@SetupUser
		 ,@SetupUser
		from
			@sample			x
		left outer join
			dbo.Country c1 on x.CountryName = c1.CountryName -- avoid existing countries; by name and ISO code
		left outer join
			dbo.Country c2 on x.ISOA3				= c2.ISOA3
		where
			c1.CountrySID is null -- only insert missing rows
			and c2.CountrySID is null;

		-- check count of @sample table and the target table
		-- target should have at least as many rows as @sample

		select @sourceCount	 = count(1) from @sample ;
		select @targetCount	 = count(1) from dbo .Country;

		if isnull(@targetCount, 0) < @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SampleTooSmall'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Insert of some sample records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'dbo.Country'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
