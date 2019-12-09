-- Testing out HTTP with DB2 --

/*
    * https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_74/rzajq/rzajqhttpoverview.htm
    * http://archive.ibmsystemsmag.com/blogs/i-can/january-2017/json_table-function/
    * Systools.HttpPostClob(:url, :header, :body)
*/


-- GET requests testing -- 
values Systools.HttpGetClob('https://api.ratesapi.io/api/latest?base=USD', '');
select * from table(Systools.HttpGetClobVerbose('https://api.ratesapi.io/api/latest?base=USD', ''));


-- Testing Anilist query --
select * from table(Systools.HttpPostClobVerbose('https://graphql.anilist.co',
    cast('<httpHeader><header name="Content-Type" value="application/json"/></httpHeader>' as clob),
    cast('{"query": "{User(search:\"barrettotte\"){id name siteUrl stats{watchedTime}}}"}' as clob))
);
-- this will be built dynamically in SQLRPGLE --



select * from json_table(
  Systools.HttpPostClob(
    'https://graphql.anilist.co',
    cast('<httpHeader><header name="Content-Type" value="application/json"/></httpHeader>' as clob),
    cast('{"query": "{User(search:\"barrettotte\"){id name siteUrl stats{watchedTime}}}"}' as clob)
  ),
  '$.data.User'
  columns(
    id char(10) path '$.id',
    name char(20) path '$.name',
    url char(32) path '$.siteUrl',
    hours char(10) path '$.stats.watchedTime'
  )
);
