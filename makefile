# ----------------------------------------------------------------------------
# Ref: https://github.com/NielsLiisberg/RPG-vsCode-Getting-Started/blob/master/makefile
#   Did not include [%.srvpgm, %.bnddir, %.entry]
# To Do:  PF's and LF's

BIN_LIB=OTTEB1
LIBLIST=$(BIN_LIB)
DBGVIEW=*ALL
TARGET_CCSID=*JOB
SHELL=/QOpenSys/usr/bin/qsh
INCLUDE='/QIBM/include' 'headers/'

# RPGLE compile
RCFLAGS=OPTION(*NOUNREF) DBGVIEW(*LIST)   INCDIR('./..')
SQLRPGCFLAGS=OPTION(*NOUNREF) DBGVIEW(*LIST)   INCDIR(''./..'')
RPGFILTER=| grep '*RNF' | grep -v '*RNF7031' | sed  "s!*!src/$*.rpgle: &!"

# C compile
CCFLAGS=OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW($(DBGVIEW)) TGTCCSID($(TARGET_CCSID))
CCFLAGSB=OPTION(*STDLOGMSG) OUTPUT(*print) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) SYSIFCOPT(*IFSIO) DBGVIEW(*ALL) INCDIR($(INCLUDE)) 


all:	$(BIN_LIB).lib aldspf.dspf anilist.sqlrpgle

copy:
	system "CPYTOSTMF FROMMBR('/QSYS.LIB/OTTEB1.LIB/QDDSSRC.FILE/ALDSPF.MBR') TOSTMF('/home/OTTEB/Anilist-IBMi/src/aldspf.dspf') STMFOPT(*REPLACE)"

# ----------------------------------------------------------------------------

%.lib:
	-system -q "CRTLIB $* TYPE(*TEST)"

%.rpgle:
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QRPGLESRC)  RCDLEN(112)"
	liblist -a $(LIBLIST);\
	setccsid 1252 src/$*.rpgle;\
	system -iK "CRTBNDRPG PGM($(BIN_LIB)/$(notdir $*)) SRCSTMF('src/$*.rpgle') $(RCFLAGS) TEXT('$(OBJECT_DESCRIPTION)')" $(RPGFILTER) ;\

%.sqlrpgle:
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QRPGLESRC)  RCDLEN(112)"
	liblist -a $(LIBLIST);\
	setccsid 1252 src/$*.sqlrpgle;
	system -iK "CRTSQLRPGI OBJ($(BIN_LIB)/$(notdir $*)) SRCSTMF('src/$*.sqlrpgle') RPGPPOPT(*LVL2) COMPILEOPT('$(SQLRPGCFLAGS)') DBGVIEW(*NONE) COMMIT(*NONE) TEXT('$(OBJECT_DESCRIPTION)')" ;\

%.cmd:
	system -q "CHGATR OBJ('cmd/$*.cmd') ATR(*CCSID) VALUE(1252)"
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QCMDSRC) RCDLEN(132)"
	system "CPYFRMSTMF FROMSTMF('cmd/$*.cmd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QCMDSRC.file/$(notdir $*).mbr') MBROPT(*REPLACE)"
	system "CRTCMD prdlib($(BIN_LIB)) cmd($(BIN_LIB)/$(notdir $*)) PGM($(notdir $*))  SRCFILE($(BIN_LIB)/QCMDSRC)"

%.pycmd:
	system -q "CHGATR OBJ('pycmd/$*.pycmd') ATR(*CCSID) VALUE(1252)"
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QCMDSRC) RCDLEN(132)"
	system "CPYFRMSTMF FROMSTMF('pycmd/$*.pycmd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QCMDSRC.file/$(notdir $*).mbr') MBROPT(*REPLACE)"
	system "CRTCMD prdlib($(BIN_LIB)) cmd($(BIN_LIB)/$(notdir $*)) PGM(runpy) SRCFILE($(BIN_LIB)/QCMDSRC)"

%.clle:
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QCLLESRC) RCDLEN(112)"
	liblist -a $(LIBLIST);\
	setccsid 1252 src/$*.clle;\
	system "CPYFRMSTMF FROMSTMF('./src/$*.clle') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QCLLESRC.file/$*.mbr') MBROPT(*replace)"
	system "CRTCLMOD MODULE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QCLLESRC) DBGVIEW($(DBGVIEW))"

%.dspf:
	system -q "CHGATR OBJ('src/$*.dspf') ATR(*CCSID) VALUE(1252)"
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QDDSSRC) RCDLEN(132)"
	system "CPYFRMSTMF FROMSTMF('src/$*.dspf') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QDDSSRC.file/$(notdir $*).mbr') MBROPT(*REPLACE)"
	system "CRTDSPF file($(BIN_LIB)/$(notdir $*)) SRCFILE($(BIN_LIB)/QDDSSRC)"

%.sql:
	system -q "CHGATR OBJ('sql/$*.sql') ATR(*CCSID) VALUE(1252)"
	system "RUNSQLSTM SRCSTMF('sql/$*.sql') COMMIT(*NONE) ERRLVL(30)"

%.c:
	system -q "CHGATR OBJ('src/$*.c') ATR(*CCSID) VALUE(1252)"
	system "CRTBNDC PGM($(BIN_LIB)/$(notdir $*)) SRCSTMF('src/$*.c') $(CCFLAGSB)"

all:
	@echo "Build finished!"

clean:
	-system -q "DLTOBJ OBJ($(BIN_LIB)/*ALL) OBJTYPE(*FILE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/*ALL) OBJTYPE(*MODULE)"
