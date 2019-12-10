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
    cast('{"query": "{User(search:\"barrettotte\"){id name siteUrl stats{watchedTime}}}"}' as clob)
));

select responsemsg from table(Systools.HttpPostClobVerbose('https://graphql.anilist.co',
    cast('<httpHeader><header name="Content-Type" value="application/json"/></httpHeader>' as clob),
    cast('{"query": "{MediaListCollection(userId:247578, type:ANIME){lists{name entries {id}}}}"}' as clob)
));


-- Get user --
select 
  id
  username,
  url,
  (minutes / 60) as hours
from json_table(
  Systools.HttpPostClob(
    'https://graphql.anilist.co',
    cast('<httpHeader><header name="Content-Type" value="application/json"/></httpHeader>' as clob),
    cast('{"query": "{User(search:\"barrettotte\"){id name siteUrl stats{watchedTime}}}"}' as clob)
  ),
  '$.data.User'
  columns(
    id       char(10) path '$.id',
    username char(20) path '$.name',
    url      char(32) path '$.siteUrl',
    minutes  char(10) path '$.stats.watchedTime'
  )
);



-- Get Anilist list counts --
with response as (
  select 
    upper(name) as name,
    id
  from json_table(
    Systools.HttpPostClob(
      'https://graphql.anilist.co',
      cast('<httpHeader><header name="Content-Type" value="application/json"/></httpHeader>' as clob),
      cast('{"query": "{MediaListCollection(userId:247578, type:ANIME){lists{name entries {id}}}}"}' as clob)
    ),
    '$.data.MediaListCollection.lists[*]' columns(
      name char(32) path '$.name',
      nested '$.entries[*]' columns(
        id char(32) path '$.id'
      )
    )
  )
)
,listCounts as (
  select name as listType, count(*) as listCount
  from response
  group by name
) select * from listCounts;
-- Pivot the list --
select
  (select count(*) from response where name = 'COMPLETED') as completed,
  (select count(*) from response where name = 'DROPPED')   as dropped,
  (select count(*) from response where name = 'PLANNING')  as planned,
  (select count(*) from response where name = 'WATCHING')  as current,
  (select count(*) from response where name = 'PAUSED')    as paused,
  (select count(*) from response where name = 'REPEATING') as repeat
from response
limit 1
;

