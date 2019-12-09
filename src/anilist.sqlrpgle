**free

ctl-opt main(main);
ctl-opt option(*srcstmt:*noDebugIO:*nounref) dftActGrp(*no);
ctl-opt datfmt(*iso) timfmt(*iso);


dcl-f ALDSPF workStn(*ext) indDs(dspf) usropn;

dcl-ds dspf qualified;
  exit     ind  pos(3);
  refresh  ind  pos(5);
  cancel   ind  pos(12);
end-ds;

dcl-pr main extPgm('ANILIST') end-pr;

// Utils 

dcl-pr openFile pointer extproc('_C_IFS_fopen');
  *n pointer value; // file name
  *n pointer value; // file mode
end-pr;

dcl-pr writeFile pointer extproc('_C_IFS_fputs');
  *n pointer value; // string to write
  *n pointer value; // open mode
end-pr;

dcl-pr closeFile extproc('_C_IFS_fclose');
  *n pointer value; // misc pointer
end-pr;

// -----


dcl-proc main;

  monitor;
    open ALDSPF;
  on-error *file;
    dsply ('Could not open display file ALDSPF');
    return;
  endmon;

  dspfLoop ();

  on-exit;
    resetDspf ();
    close *ALL;

end-proc;


dcl-proc dspfLoop;
  monitor;
    doU (dspf.exit);
      exfmt ALDR001;

      if (dspf.cancel or dspf.exit);
        leave;
      elseif (dspf.refresh);
        ALDOERROR = '';
        write ALDR001;
      elseif (ALDIUSRNM <> *BLANK);
        queryAnilist ();
        write ALDR001;
      endif;
      
    enddo;
  on-error;
    ALDOERROR = 'Error in dspfLoop()';
    write ALDR001;
  endmon;
end-proc;


dcl-proc queryAnilist;
  // todo take user as param, return resp DS

  // /set ccsid(*CHAR:37)

  dcl-ds user qualified;
    id     varchar(10);
    name   varchar(20);
    url    varchar(32);
    hours  varchar(10);
  end-ds;
  
  dcl-ds listCounts qualified;
    completed  varchar(4);
    dropped    varchar(4);
    planned    varchar(4);
    current    varchar(4);
    paused     varchar(4);
    repeat     varchar(4);
  end-ds;

  dcl-s alApiUrl  varchar(128);
  dcl-s reqHeader varchar(128);
  dcl-s reqBody   varchar(256);

  // /restore ccsid(*CHAR)

  // ======= Debug response =======
  dcl-s pathFile  char(50);
  dcl-s openMode  char(100);
  dcl-s filePtr   pointer inz;
  dcl-s response  varchar(4000);
  // ==============================
  
  alApiUrl = 'https://graphql.anilist.co';
  reqHeader = '<httpHeader>' + 
    '<header name="Content-Type"' + 
    ' value="application/json"/>' +
    '</httpHeader>';
  reqBody = '{"query": "{User(search:\"' +
    'barrettotte' +  //%trim(ALDIUSRNM) +
    '\"){id name siteUrl stats{watchedTime}}}"}';
  
  monitor;
    exec SQL
      select
        id,
        name,
        url,
        (minutes / 60) as hours 
      into :user
      from json_table(cast(
        Systools.HttpPostClob(
          cast(:alApiUrl  as clob ccsid 37),
          cast(:reqHeader as clob ccsid 37),
          cast(:reqBody   as clob ccsid 37)
        )
        as clob ccsid 37
      ), 
      '$.data.User'
      columns(
        id       varchar(10) path '$.id',
        name     varchar(20) path '$.name',
        url      varchar(32) path '$.siteUrl',
        minutes  varchar(10) path '$.stats.watchedTime'
      )
    ) as X;
    
    ALDOID = user.id;
    ALDONAME = user.name;
    ALDOURL = user.url;
    ALDOHOURS = user.hours;

    // todo : DRY

  on-error;
    ALDOERROR = 'Error in queryAnilist()';
  endmon;

  // todo : move to util subproc
  // ===================DEBUG response=========================
  // pathFile = '/home/OTTEB/Anilist-IBMi/response.txt' + x'00';
  // openMode = 'w, o_ccsid=1252' + x'00';
  // filePtr = openFile(%addr(pathFile): %addr(openMode));
  // if (filePtr = *null);
  //   dsply ('Unable to open file.');
  //   return;
  // endif;
  // writeFile(%addr(response): filePtr);
  // closeFile(%addr(pathFile));
  // ==========================================================

end-proc;


dcl-proc resetDspf;
  // For some reason, I need to reset indicators 
  //   even after closing a DSPF successfully. 
  //   I should look more into this at some point.
  clear ALDR001;
  dspf.exit = *OFF;
  dspf.cancel = *OFF;
end-proc;


dcl-proc toUpper;
  dcl-pi *n char(80);
    s char(80) value;
  end-pi;

  exec SQL 
    set :s = upper(:s);
  return s;
end-proc;
