
CREATE TABLE emp(jsondoc VARCHAR(32000) CCSID 1208);

INSERT INTO emp VALUES
'{"id":901, "name" : { "first":"John", "last":"Doe" }, "office" : "E-334",
"phones" : [ { "type":"home", "number":"555-3762" },
             { "type":"work", "number":"555-7242" } ],
"accounts" : [ { "number":"36232"}, { "number":"73263"}] }';

INSERT INTO emp VALUES
'{"id":902, "name" : { "first":"Peter", "last":"Pan" }, "office" : "E-216",
"phones" : [ { "type":"work", "number":"555-8925" } ],
"accounts" : [ { "number":"76232"}, {"number":"72963"}] }';

INSERT INTO emp VALUES
'{"id":903, "name" : { "first":"Mary", "last":"Jones" }, "office" : "E-739",
"phones" : [ { "type":"work", "number":"555-4311" },
             { "type":"home", "number":"555-6312" } ], }';

INSERT INTO emp VALUES
'{"id":904, "name" : { "first":"Sally", "last":"Smith" } }';
