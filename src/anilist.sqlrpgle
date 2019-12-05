**free

ctl-opt option(*srcStmt :*noDebugIO) dftActGrp(*no);
ctl-opt main(main);

/INCLUDE './headers/anilist_h.rpgle'

dcl-proc main;
  exec SQL
    set option commit = *NONE, datFmt = *ISO;

  dcl-s x char(40);
  x = toUpperCase('hello');

  dsply (x);

  return;
end-proc;

dcl-proc toUpperCase;
  dcl-pi *n char(40);
    textIn char(40) const;
  end-pi;
  dcl-s textOut char(40);

  exec SQL
    values upper(:textIn) into :textOut;
  return textOut;
end-proc;
