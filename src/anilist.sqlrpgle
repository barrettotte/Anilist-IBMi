**free

ctl-opt option(*srcstmt :*noDebugIO: *nounref) dftActGrp(*no);
ctl-opt datfmt(*iso) timfmt(*iso);
ctl-opt main(main);


dcl-pr main extPgm('ANILIST') end-pr;

dcl-f ANISEARCH workstn indDs(dspInds);

dcl-ds dspInds;
  exit_03    ind pos(3);
  refresh_05 ind pos(5);
end-ds;

dcl-proc main;
  
  exfmt ALDR001;

  doW not exit_03;
    if exit_03;
      leave;
    endif;
    exfmt ALDR001;
  enddo;

  dsply ('hello');
  
  return;
end-proc;
