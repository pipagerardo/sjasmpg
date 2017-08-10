/*

  Sjasm Z80 Assembler version 0.42

  Copyright 2011 Sjoerd Mastijn

  This software is provided 'as-is', without any express or implied warranty.
  In no event will the authors be held liable for any damages arising from the
  use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it freely,
  subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not claim
     that you wrote the original software. If you use this software in a product,
     an acknowledgment in the product documentation would be appreciated but is
     not required.

  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.

  3. This notice may not be removed or altered from any source distribution.

*/

/*
	Copyright 2017 PipaGerardo               E-Mail: pipagerardo@gmail.com
	SjasmPG Ensamblador para el microprocesador de 8 bits Z80
	Basado en Sjasm v42c de Sjoerd Mastijn Copyright 2011 - www.xl2s.tk
*/

// directives.cpp
#include "sjasmpg.h"
// #include "directives.h"

#ifdef LANGUAGE_UTF8
#include "language_utf8.h"
#else
#include "language_iso.h"
#endif

// StringList printfile;
string printfile;
void printOutput() {
	if( !printfile.empty() ) {
		WriteFile file( printfilename );
		file.write( printfile );
		file.close();
	}
}

int prevorg=0, prevsize=-1;

void dirZ80( string &line, RawSource *rs ) {
	piCPU=pimsx;
	rs->GetSource().push_back( new ListMode( plist=listlistlinez80 ) );
	checkjunk( line );
}

#ifdef METARM
void dirTHUMB( string &line, RawSource *rs ) {
	piCPU=pithumb;
	rs->GetSource().push_back(new ListMode(plist=listlistline16));
	checkjunk(line);
}

void dirARM( string &line, RawSource *rs ) {
	piCPU=piarm;
	rs->GetSource().push_back(new ListMode(plist=listlistline32));
	checkjunk(line);
}
#endif

void dirEND( string &line, RawSource * ) {
	stop._stop=END;
	checkjunk(line);
}

void dirORG( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dOrg(line));
	rs->GetSource().back()->Process();
}

void dirCODE( string &line, RawSource *rs ) {
	Rout *r=output[onr]->getnewroutp();
	int rnr=output[onr]->getrout();
	if (!phasestack.empty()) error( EM_CODE_not_allowed_in_PHASE );
	rs->GetSource().push_back(new dPool()); //
	rs->GetSource().push_back(new dRout(rnr,r,line));
	rs->GetSource().back()->Process();
}

void dirMODULE( string &line, RawSource *rs ) {
	string n=getid(line);
	checkjunk(line);
	modulestack.push(modlabp);
	rs->GetSource().push_back(new SetModule(n));
	rs->GetSource().back()->Process();
}

void dirENDMODULE( string &line, RawSource *rs ) {
	string n=getid(line); checkjunk(line);
	if (modulestack.empty()) { error(EM_ENDMODULE_without_MODULE); return; }
	if (n.empty() || n==modlabp) {
		modlabp=modulestack.top(); modulestack.pop();
	} else {
		do {
			if (modulestack.empty()) { error(EM_MODULE_not_found); break; }
			modlabp=modulestack.top(); modulestack.pop();
		} while (n!=modlabp);
		if (modulestack.empty()) modlabp.clear();
		else { modlabp=modulestack.top(); modulestack.pop(); }
	}
	rs->GetSource().push_back(new SetModule(modlabp));
	rs->GetSource().back()->Process();
}

void dirPAGE( string &line, RawSource *rs ) {
	Rout *r=output[onr]->getnewroutp();
	int rnr=output[onr]->getrout();
	rs->GetSource().push_back(new dPool()); //
	rs->GetSource().push_back(new dPage(rnr,r,line));
	rs->GetSource().back()->Process();
}

void dirDEFPAGE( string &line, RawSource * ) {
	int firstpage, lastpage, org, size, val;
	if (!ParseExpression(line,firstpage)) { error(EM_Syntax_error,ERRREP); return; }
	if (labelnotfound) error(EM_Forward_reference);
	if (firstpage<0 || firstpage>255) { error(EM_Illegal_pagenumber); return; }
	if (need(line,(char*)"..")) {
		if (!ParseExpression(line,lastpage)) { error(EM_Syntax_error,ERRREP); return; }
		if (labelnotfound) error(EM_Forward_reference);
		if (lastpage<0 || firstpage>lastpage) { error(EM_Illegal_pagenumber); return; }
	} else lastpage=firstpage;
	if (comma(line)) {
		if (sbcneed(line,'*')) {
			val=-1;
		} else {
			if (!ParseExpression(line,val)) { error(EM_Syntax_error,ERRREP); return; }
			if (labelnotfound) error(EM_Forward_reference);
			if (val<0) { val=0; error(EM_Negative_origin); }
		}
		prevorg=val;
		if (comma(line)) {
			if (sbcneed(line,'*')) {
				val=-1;
			} else {
				if (!ParseExpression(line,val)) { error(EM_Syntax_error,ERRREP); return; }
				if (labelnotfound) error(EM_Forward_reference);
				if (val<0) { val=0; error(EM_Negative_size); }
			}
			prevsize=val;
		}
	}
	org=prevorg; size=prevsize;
	for (val=firstpage;val<=lastpage;++val) output[onr]->defpage(val,org,size);
	checkjunk(line);
}

void dirMAPALIGN( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dMapAlign(line));
	rs->GetSource().back()->Process();
}

void dirMAP( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dMap(line));
	rs->GetSource().back()->Process();
}

void dirENDMAP( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dEndmap());
	rs->GetSource().back()->Process();
	checkjunk(line);
}

void dirALIGN( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dAlign(line));
	rs->GetSource().back()->Process();
}

void dirPHASE( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dPhase(line));
	rs->GetSource().back()->Process();
}

void dirDEPHASE( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dDephase());
	rs->GetSource().back()->Process();
	checkjunk(line);
}
/*
void dirINCBIN( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dIncbin(line,list));
	rs->GetSource().back()->Process();
}
*/
void dirINCBINDOT( string &line, RawSource *rs ) {
	string p;
	bool list=options.listbincludes;
	while (!line.empty() && line[0]=='.') {
		line.erase(0,1); p=getinstructionpart(line);
		if (p=="list") list=true;
		else if (p=="nolist") list=false;
		else error(EM_Unknown_instruction,"incbin."+p);
	}
	rs->GetSource().push_back(new dIncbin(line,list));
	rs->GetSource().back()->Process();
}

void getoutput( string &line, RawSource *rs, FILEMODE m ) {
	string n=getfilename(line);
	output.push_back(new Output(n,m));
	onr=(int)output.size()-1;
	rs->GetSource().push_back(new SetOutput(onr));
	rs->GetSource().back()->Process();
	checkjunk(line); line.clear();
	dirCODE(line,rs);
}

void dirOUTPUT( string &line, RawSource *rs ) {
	getoutput( line, rs, OVERWRITE );
}

void dirUPDATE( string &line, RawSource *rs ) {
	getoutput( line, rs, UPDATE );
}

void dirINCDIR( string &line, RawSource * ) {
	skipblanks(line);
	paths.insert(paths.begin(),line);
}

void dirASSERT( string &line, RawSource *rs ) {
	rs->GetSource().push_back(new dAssert(line));
}

void dirSIZE( string &line, RawSource * ) {
	int ns;
	if (!ParseExpression(line,ns)) { error(EM_Syntax_error,ERRREP); return; }
	if (labelnotfound) error(EM_Forward_reference);
	if (ns<0) { ns=-1; error(EM_Negative_size); }
	output[onr]->setpagesize(ns);
	checkjunk(line);
}

void dirERROR( string &line, RawSource * ) {
	skipblanks(line);
	error(line,ERRPASS1);
	line.clear();
}

void prePRINTSTR( string &line, RawSource * ) {
	skipblanks( line );
 	string l;
 	getstring( line, l );   // Quita las comillas y da error
 	int val = 0;
 	if( comma(line) ) {
		if (!ParseExpression(line,val)) error1(EM_Expression_expected);
		if (labelnotfound) error( EM_Label_not_found );
		if( val > 256 ) val = 0;
	}
	cout << l; for( int i = 0; i < val; ++i ) cout << endl;
	for( int i = 0; i < val; ++i ) l.append( "\r\n" );
	printfile.append( l );
	line.clear();
}

void prePRINTDEC( string &line, RawSource * ) {
	if( line.empty() ) return;
	int val =  0;
	int n = 0;
	if (!ParseExpression(line,val)) error1(EM_Expression_expected);
	if (labelnotfound) error( EM_Label_not_found );
	if( comma(line) ) {
		if (!ParseExpression(line,n)) error1(EM_Expression_expected);
		if (labelnotfound) error( EM_Label_not_found );
	}
	ostringstream s;
	if( n != 0 ) {
		s.width( n );
		s.fill('0');
	}
	s.flags( ios::dec );
	s << val;
	string l = s.str();
	cout << l;
	printfile.append( l );
	line.clear();
}

void prePRINTHEX( string &line, RawSource * ) {
	if( line.empty() ) return;
	int val =  0;
	int n = 0;
	if (!ParseExpression(line,val)) error1(EM_Expression_expected);
	if(labelnotfound) error( EM_Label_not_found );
	if( comma(line) ) {
		if (!ParseExpression(line,n)) error1(EM_Expression_expected);
		if (labelnotfound) error( EM_Label_not_found );
	}
	ostringstream s;
	if( n != 0 ) {
		s.width( n );
		s.fill('0');
	}
	s.flags( ios::hex | ios::uppercase );
	s << val;
	string l = s.str();
	cout << l;
	printfile.append( l );
	line.clear();
}

void prePRINTENDL( string &line, RawSource * ) {
 	cout << endl;
 	string l = "\r\n";
	printfile.append( l );
	line.clear();
}

void prePRINTSTRDEC( string &line, RawSource * ) {
	skipblanks( line );
 	string l;
 	getstring( line, l );   // Quita las comillas y da error
	int val = 0;
	int n = 0;
	if( comma(line) ) {
		if (!ParseExpression(line,val)) error1(EM_Expression_expected);
		if (labelnotfound) error( EM_Label_not_found );
		if( comma(line) ) {
			if (!ParseExpression(line,n)) error1(EM_Expression_expected);
			if (labelnotfound) error( EM_Label_not_found );
		}
		ostringstream s;
		if( n != 0 ) {
			s.width( n );
			s.fill('0');
		}
		s.flags( ios::dec );
		s << val;
		l.append( s.str() );
	}
	cout << l << endl;
	l.append( "\r\n" );
	printfile.append( l );
	line.clear();
}

void prePRINTSTRHEX( string &line, RawSource * ) {
	skipblanks( line );
 	string l;
 	getstring( line, l );   // Quita las comillas y da error
	int val = 0;
	int n = 0;
	if( comma(line) ) {
		if (!ParseExpression(line,val)) error1(EM_Expression_expected);
		if (labelnotfound) error( EM_Label_not_found );
		if( comma(line) ) {
			if (!ParseExpression(line,n)) error1(EM_Expression_expected);
			if (labelnotfound) error( EM_Label_not_found );
		}
		ostringstream s;
		if( n != 0 ) {
			s.width( n );
			s.fill('0');
		}
		s.flags( ios::hex | ios::uppercase );
		s << val;
		l.append( s.str() );
	}
	cout << l << endl;
	l.append( "\r\n" );
	printfile.append( l );
	line.clear();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FunctionTable<pFun,RawSource> dirfuntab;

void initDir() {
	FunctionEntry<pFun> funs[] = {
		{(char*)"end",dirEND},
		{(char*)"code",dirCODE},
		{(char*)"module",dirMODULE},
		{(char*)"endmodule",dirENDMODULE},
		{(char*)"page",dirPAGE},
		{(char*)"defpage",dirDEFPAGE},
		{(char*)"##",dirMAPALIGN},
		{(char*)"mapalign",dirMAPALIGN},
		{(char*)"map",dirMAP},
		{(char*)"endmap",dirENDMAP},
		{(char*)"align",dirALIGN},
		{(char*)"phase",dirPHASE},
		{(char*)"dephase",dirDEPHASE},
		{(char*)"incbin",/*dirINCBIN,*/ dirINCBINDOT},
		{(char*)"output",dirOUTPUT},
		{(char*)"update",dirUPDATE},
		{(char*)"incdir",dirINCDIR},
		{(char*)"assert",dirASSERT},
		{(char*)"org",dirORG},
		{(char*)"size",dirSIZE},
		{(char*)"error",dirERROR},
		{(char*)"z80",dirZ80},
#ifdef METARM
		{(char*)"thumb",dirTHUMB},
		{(char*)"arm",dirARM},
#endif
		{(char*)"incbin.",dirINCBINDOT},
 		{(char*)"printstr",prePRINTSTR},  		// Imprime una cadena de texto [, cantidad_endl ]
 		{(char*)"printdec",prePRINTDEC},  		// Imprime valor en decimal [, ancho]
 		{(char*)"printhex",prePRINTHEX},			// Imprime valor en hexadecimal [, ancho]
 		{(char*)"printendl",prePRINTENDL},		// Imprime un final de linea "\r\n"
 		{(char*)"printstrdec",prePRINTSTRDEC},	// Imprime STR + [, DEC] [, ancho] + ENDL
 		{(char*)"printstrhex",prePRINTSTRHEX}		// Imprime STR + [, HEX] [, ancho] + ENDL
	};
	dirfuntab.init(funs, sizeof funs/sizeof funs[0]);

}

//eof
