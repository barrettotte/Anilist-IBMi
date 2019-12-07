**free

ctl-opt main(main);
ctl-opt option(*srcstmt :*noDebugIO: *nounref) dftActGrp(*no);
ctl-opt datfmt(*iso) timfmt(*iso);

dcl-f ALDSPF workstn indDs(dspf) usropn;

dcl-ds dspf qualified;
  exit    ind pos(3);
  refresh ind pos(5);
end-ds;

dcl-pr main extPgm('ANILIST') end-pr;


dcl-proc main;
  open ALDSPF;
  
  doW not dspf.exit;
    exfmt ALDR001;
  enddo;

  resetDspf();

  on-exit;
    close *ALL;

end-proc;


dcl-proc resetDspf;
  // For some reason, I need to reset indicators 
  //   even after closing a DSPF successfully. 
  //   I should look more into this at some point.
  dspf.exit = *OFF;
end-proc;


dcl-proc toUpper;
  dcl-pi *n char(80);
    s char(80) value;
  end-pi;

  exec SQL set :s = upper(:s);
  return s;
end-proc;
