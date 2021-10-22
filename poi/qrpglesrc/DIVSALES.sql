-- This creates the DIVSALES file used by the XLCRTDEMO/HDRDEMO
-- sample programs, and puts some test data into the file.
--                                 Scott Klement, February 25, 2010
Create Table DIVSALES (
   MonthNo  numeric(2, 0),
   DivNo    numeric(3, 0),
   DivName  char(30),
   PostDate Date,
   Sales    decimal(11, 2),
   primary key (MonthNo, Divno)
)
rcdfmt DIVSALESF;
Insert into DIVSALES Values( 1,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             22163.70);
Insert into DIVSALES Values( 1,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             452007.00);
Insert into DIVSALES Values( 1,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             22028.30);
Insert into DIVSALES Values( 1,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             20439.10);
Insert into DIVSALES Values( 1,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             881045.10);
Insert into DIVSALES Values( 1,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 1,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             20325.50);
Insert into DIVSALES Values( 1,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             20773.00);
Insert into DIVSALES Values( 1,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             358311.20);
Insert into DIVSALES Values( 1,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 1,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             159575.70);
Insert into DIVSALES Values( 1,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             49061.30);
Insert into DIVSALES Values( 1,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             219196.30);
Insert into DIVSALES Values( 1,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             146526.60);
Insert into DIVSALES Values( 1,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             188137.50);
Insert into DIVSALES Values( 1,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             79127.60);
Insert into DIVSALES Values( 1,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             10056.60);
Insert into DIVSALES Values( 2,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             50866.50);
Insert into DIVSALES Values( 2,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             274040.00);
Insert into DIVSALES Values( 2,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             28947.50);
Insert into DIVSALES Values( 2,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             26900.00);
Insert into DIVSALES Values( 2,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             921909.60);
Insert into DIVSALES Values( 2,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 2,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             9564.00);
Insert into DIVSALES Values( 2,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             18711.20);
Insert into DIVSALES Values( 2,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             493070.30);
Insert into DIVSALES Values( 2,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 2,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             230268.80);
Insert into DIVSALES Values( 2,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             50614.60);
Insert into DIVSALES Values( 2,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             206440.20);
Insert into DIVSALES Values( 2,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             151249.20);
Insert into DIVSALES Values( 2,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             185268.90);
Insert into DIVSALES Values( 2,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             91571.50);
Insert into DIVSALES Values( 2,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             14726.50);
Insert into DIVSALES Values( 3,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             22068.00);
Insert into DIVSALES Values( 3,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             269953.00);
Insert into DIVSALES Values( 3,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             81242.50);
Insert into DIVSALES Values( 3,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             29376.00);
Insert into DIVSALES Values( 3,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             733687.90);
Insert into DIVSALES Values( 3,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 3,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             12676.00);
Insert into DIVSALES Values( 3,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             15692.70);
Insert into DIVSALES Values( 3,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             618199.00);
Insert into DIVSALES Values( 3,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 3,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             258231.90);
Insert into DIVSALES Values( 3,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             78426.30);
Insert into DIVSALES Values( 3,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             214219.50);
Insert into DIVSALES Values( 3,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             173616.50);
Insert into DIVSALES Values( 3,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             240489.50);
Insert into DIVSALES Values( 3,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             120838.20);
Insert into DIVSALES Values( 3,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             24202.80);
Insert into DIVSALES Values( 4,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             38720.00);
Insert into DIVSALES Values( 4,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             401015.00);
Insert into DIVSALES Values( 4,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             83701.00);
Insert into DIVSALES Values( 4,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             38584.00);
Insert into DIVSALES Values( 4,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             715236.50);
Insert into DIVSALES Values( 4,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 4,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             19415.60);
Insert into DIVSALES Values( 4,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             22455.30);
Insert into DIVSALES Values( 4,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             721810.30);
Insert into DIVSALES Values( 4,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 4,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             282051.80);
Insert into DIVSALES Values( 4,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             78746.00);
Insert into DIVSALES Values( 4,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             216262.00);
Insert into DIVSALES Values( 4,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             239317.10);
Insert into DIVSALES Values( 4,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             320194.80);
Insert into DIVSALES Values( 4,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             150286.20);
Insert into DIVSALES Values( 4,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             18460.70);
Insert into DIVSALES Values( 5,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             46718.50);
Insert into DIVSALES Values( 5,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             265839.00);
Insert into DIVSALES Values( 5,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             63480.90);
Insert into DIVSALES Values( 5,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             20044.00);
Insert into DIVSALES Values( 5,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             982719.20);
Insert into DIVSALES Values( 5,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 5,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             14998.70);
Insert into DIVSALES Values( 5,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             19506.00);
Insert into DIVSALES Values( 5,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             702618.80);
Insert into DIVSALES Values( 5,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 5,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             267780.50);
Insert into DIVSALES Values( 5,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             89408.60);
Insert into DIVSALES Values( 5,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             242586.40);
Insert into DIVSALES Values( 5,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             234916.70);
Insert into DIVSALES Values( 5,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             305769.50);
Insert into DIVSALES Values( 5,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             104689.40);
Insert into DIVSALES Values( 5,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             30526.70);
Insert into DIVSALES Values( 6,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             40051.00);
Insert into DIVSALES Values( 6,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             301920.00);
Insert into DIVSALES Values( 6,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             85576.70);
Insert into DIVSALES Values( 6,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             28843.20);
Insert into DIVSALES Values( 6,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             636085.60);
Insert into DIVSALES Values( 6,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 6,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             5020.00);
Insert into DIVSALES Values( 6,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             25646.50);
Insert into DIVSALES Values( 6,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             745966.50);
Insert into DIVSALES Values( 6,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 6,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             232241.90);
Insert into DIVSALES Values( 6,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             97481.40);
Insert into DIVSALES Values( 6,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             274768.10);
Insert into DIVSALES Values( 6,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             208383.90);
Insert into DIVSALES Values( 6,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             323029.80);
Insert into DIVSALES Values( 6,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             175381.60);
Insert into DIVSALES Values( 6,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             16481.10);
Insert into DIVSALES Values( 7,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             28495.50);
Insert into DIVSALES Values( 7,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             433029.00);
Insert into DIVSALES Values( 7,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             54918.00);
Insert into DIVSALES Values( 7,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             29230.50);
Insert into DIVSALES Values( 7,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             639516.80);
Insert into DIVSALES Values( 7,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 7,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             19750.50);
Insert into DIVSALES Values( 7,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             17690.80);
Insert into DIVSALES Values( 7,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             415327.80);
Insert into DIVSALES Values( 7,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 7,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             181406.80);
Insert into DIVSALES Values( 7,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             220944.00);
Insert into DIVSALES Values( 7,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             264993.20);
Insert into DIVSALES Values( 7,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             157993.80);
Insert into DIVSALES Values( 7,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             255700.70);
Insert into DIVSALES Values( 7,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             170169.80);
Insert into DIVSALES Values( 7,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             15571.10);
Insert into DIVSALES Values( 8,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             24852.00);
Insert into DIVSALES Values( 8,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             635828.00);
Insert into DIVSALES Values( 8,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             50419.60);
Insert into DIVSALES Values( 8,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             26287.50);
Insert into DIVSALES Values( 8,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             825117.00);
Insert into DIVSALES Values( 8,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 8,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             21151.60);
Insert into DIVSALES Values( 8,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             20242.00);
Insert into DIVSALES Values( 8,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             585088.70);
Insert into DIVSALES Values( 8,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 8,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             196076.30);
Insert into DIVSALES Values( 8,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             149217.50);
Insert into DIVSALES Values( 8,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             234235.40);
Insert into DIVSALES Values( 8,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             273170.00);
Insert into DIVSALES Values( 8,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             248333.70);
Insert into DIVSALES Values( 8,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             188085.70);
Insert into DIVSALES Values( 8,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             39349.80);
Insert into DIVSALES Values( 9,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             26288.00);
Insert into DIVSALES Values( 9,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             332939.30);
Insert into DIVSALES Values( 9,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             61980.20);
Insert into DIVSALES Values( 9,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             35182.80);
Insert into DIVSALES Values( 9,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             625623.20);
Insert into DIVSALES Values( 9,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 9,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             32058.80);
Insert into DIVSALES Values( 9,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             22727.10);
Insert into DIVSALES Values( 9,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             530868.00);
Insert into DIVSALES Values( 9,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 9,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             209393.40);
Insert into DIVSALES Values( 9,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             179320.50);
Insert into DIVSALES Values( 9,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             248784.80);
Insert into DIVSALES Values( 9,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             189532.00);
Insert into DIVSALES Values( 9,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             219773.80);
Insert into DIVSALES Values( 9,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             170709.10);
Insert into DIVSALES Values( 9,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             64421.40);
Insert into DIVSALES Values( 10,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             17044.00);
Insert into DIVSALES Values( 10,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             650481.00);
Insert into DIVSALES Values( 10,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             58884.80);
Insert into DIVSALES Values( 10,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             39113.10);
Insert into DIVSALES Values( 10,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             608767.90);
Insert into DIVSALES Values( 10,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 10,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             6418.70);
Insert into DIVSALES Values( 10,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             14972.60);
Insert into DIVSALES Values( 10,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             421747.80);
Insert into DIVSALES Values( 10,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 10,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             385291.40);
Insert into DIVSALES Values( 10,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             110364.40);
Insert into DIVSALES Values( 10,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             185158.20);
Insert into DIVSALES Values( 10,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             241724.30);
Insert into DIVSALES Values( 10,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             150775.70);
Insert into DIVSALES Values( 10,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             125212.60);
Insert into DIVSALES Values( 10,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             23718.20);
Insert into DIVSALES Values( 11,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             23456.50);
Insert into DIVSALES Values( 11,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             493870.50);
Insert into DIVSALES Values( 11,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             50822.80);
Insert into DIVSALES Values( 11,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             77458.00);
Insert into DIVSALES Values( 11,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             556212.30);
Insert into DIVSALES Values( 11,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 11,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             9312.00);
Insert into DIVSALES Values( 11,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             17665.80);
Insert into DIVSALES Values( 11,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             405097.30);
Insert into DIVSALES Values( 11,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 11,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             163642.90);
Insert into DIVSALES Values( 11,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             159970.80);
Insert into DIVSALES Values( 11,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             154508.10);
Insert into DIVSALES Values( 11,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             271346.60);
Insert into DIVSALES Values( 11,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             180083.80);
Insert into DIVSALES Values( 11,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             117420.70);
Insert into DIVSALES Values( 11,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             35716.30);
Insert into DIVSALES Values( 12,
                             193,
                             'SOUTHEAST USA',
                             '2010-02-22',
                             22261.00);
Insert into DIVSALES Values( 12,
                             194,
                             'OUTER BID ACCTS',
                             '2010-02-22',
                             588759.00);
Insert into DIVSALES Values( 12,
                             195,
                             'MIDWEST',
                             '2010-02-22',
                             50372.70);
Insert into DIVSALES Values( 12,
                             196,
                             'MISC BID ACCTS',
                             '2010-02-22',
                             24516.00);
Insert into DIVSALES Values( 12,
                             197,
                             'ACME INC',
                             '2010-02-22',
                             356030.30);
Insert into DIVSALES Values( 12,
                             212,
                             'DELI',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 12,
                             213,
                             'NORTHEAST USA',
                             '2010-02-22',
                             13086.80);
Insert into DIVSALES Values( 12,
                             240,
                             'FOOD SERVICE-MILITARY',
                             '2010-02-22',
                             10813.20);
Insert into DIVSALES Values( 12,
                             241,
                             'SOUTHERN WISCONSIN',
                             '2010-02-22',
                             450335.50);
Insert into DIVSALES Values( 12,
                             242,
                             'NORTHERN WISCONSIN & U/P',
                             '2010-02-22',
                             .00);
Insert into DIVSALES Values( 12,
                             243,
                             'MINNESOTA',
                             '2010-02-22',
                             199277.40);
Insert into DIVSALES Values( 12,
                             244,
                             'MIDDLE USA STATES / BID ACCTS.',
                             '2010-02-22',
                             115009.80);
Insert into DIVSALES Values( 12,
                             245,
                             'FOOD SERVICE-NATL',
                             '2010-02-22',
                             122765.70);
Insert into DIVSALES Values( 12,
                             246,
                             'SOUTHWEST / WEST COAST USA',
                             '2010-02-22',
                             280271.50);
Insert into DIVSALES Values( 12,
                             247,
                             'FOOD SERVICE',
                             '2010-02-22',
                             148018.40);
Insert into DIVSALES Values( 12,
                             248,
                             'FRONT OFFICE / OTHERS',
                             '2010-02-22',
                             134118.10);
Insert into DIVSALES Values( 12,
                             249,
                             'SNACK SALES',
                             '2010-02-22',
                             9249.40);
