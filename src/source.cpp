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

// source.cpp
#include "sjasmpg.h"
// #include "source.h"

#ifdef LANGUAGE_UTF8
#include "language_utf8.h"
#else
#include "language_iso.h"
#endif

ListOpt listopt;
pListMode plist=listlistlinez80;

// Estructura para MACRO:
struct mac {
	mac( string n_maclabp, string n_name, string n_file, int n_line ) :
		_maclabp(n_maclabp), _name(n_name), _file(n_file), _line(n_line) {}
	string _maclabp, _name, _file;
	int _line;
};

stack<string> modulestack;
stack<int> mapadrstack;
stack<phaseinfo> phasestack;
stack<mac> macstack;
vector<int> repeatstack;
StringList listfile;
bool forget; // :(

void process( SourceList sl ) {
	for( iSourceList isl=sl.begin(); isl!=sl.end(); ++isl ) (*isl)->Process();
}

//void (*plist)(int,int,int,string&,Data&,string&);

void listlistlinez80( int curlin, int page, int adr, string &line, Data &e, string &i ) {
	string ll(40,' ');
	ll.replace(0,8,tostr(curlin,8));
	ll.replace(8,2,line.substr(0,2));
	ll.replace(11,2,tohex(page,2));
	ll.replace(14,4,tohex(adr&65535));
	ll[38]=line[2]; ll[13]=adr>65535?'!':':';
	ll+=line.substr(3);
	if (forget) ll[38]='-';
	else if (e.empty()) {
		ll.replace(20,i.size(),i);
	} else {
		if (e.size()<7) {
			for( int t=0; t!=e.size(); ++t ) ll.replace(20+t*3,2,tohex(e[t],2));
		} else {
			listfile.push_back(ll);
			string l2;
			int t=0;
			while(1) {
					if(!(t&15)) { l2=ll.substr(0,20); adr+=16; ll.replace(14,4,tohex(adr)); }
				l2+=tohex(e[t],2)+' '; ++t;
				if( t==e.size() ) { ll=l2; break; }
				if( !(t&15) ) listfile.push_back(l2);
			}
		}
	}
	listfile.push_back(ll);
}

#ifdef METARM
void listlistline8( int curlin, int page, int adr, string &line, Data &e, string &i ) {
	string ll(40,' ');
	ll.replace(0,8,tostr(curlin,8));
	ll.replace(8,2,line.substr(0,2));
	ll.replace(11,2,tohex(page,2));
	ll.replace(14,8,tohex(adr,8));
	ll[38]=line[2]; ll[13]=':';
	ll+=line.substr(3);
	if (forget) ll[38]='-';
	else if (e.empty()) {
		ll.replace(24,i.size(),i);
	} else {
		if (e.size()<5) {
			for (int t=0; t!=e.size(); ++t) ll.replace(24+t*3,2,tohex(e[t],2));
		} else {
			listfile.push_back(ll);
			string l2;
			int t=0;
			while(1) {
				if( !(t&15) ) { l2=ll.substr(0,24); adr+=16; ll.replace(14,8,tohex(adr,8)); }
				l2+=tohex(e[t],2)+' '; ++t;
				if( t==e.size() ) { ll=l2; break; }
				if( !(t&15) ) listfile.push_back(l2);
			}
		}
	}
	listfile.push_back(ll);
}

void listlistline16( int curlin, int page, int adr, string &line, Data &e, string &i ) {
	if (e.size()&1) { listlistline8(curlin,page,adr,line,e,i); return; }
	string ll(40,' ');
	ll.replace(0,8,tostr(curlin,8));
	ll.replace(8,2,line.substr(0,2));
	ll.replace(11,2,tohex(page,2));
	ll.replace(14,8,tohex(adr,8));
	ll[38]=line[2]; ll[13]=':';
	ll+=line.substr(3);
	if (forget) ll[38]='-';
	else if (e.empty()) {
		ll.replace(24,i.size(),i);
	} else {
		switch(e.size()) {
#ifdef _DEBUG
			case 0: case 1: case 3:
				cout << EM_Hoppa_Noppa << endl;
			break;
#endif
			case 4:
				ll.replace(29,4,tohex(e[2]+256*e[3]));
			case 2:
				ll.replace(24,4,tohex(e[0]+256*e[1]));
			break;
			default:
#ifdef _DEBUG
				if (e.size()&1) cout << EM_Hoppa_Noppa << endl;
#endif
				listfile.push_back(ll);
				string l2;
				int t=0;
				while(1) {
					if (!(t&15)) { l2=ll.substr(0,24); adr+=16; ll.replace(14,8,tohex(adr,8)); }
					l2+=tohex(e[t]+256*e[t+1])+' '; t+=2;
					if (t==e.size()) { ll=l2; break; }
					if (!(t&15)) listfile.push_back(l2);
				}
			break;
		}
	}
	listfile.push_back(ll);
}

void listlistline32( int curlin, int page, int adr, string &line, Data &e, string &i ) {
	if( e.size()&3 ) { listlistline16(curlin,page,adr,line,e,i); return; }
	string ll(40,' ');
	ll.replace(0,8,tostr(curlin,8));
	ll.replace(8,2,line.substr(0,2));
	ll.replace(11,2,tohex(page,2));
	ll.replace(14,8,tohex(adr,8));
	ll[38]=line[2]; ll[13]=':';
	ll+=line.substr(3);
	if (forget) ll[38]='-';
	else if( e.empty() ) {
		ll.replace(24,i.size(),i);
	} else {
		switch( e.size() ) {
#ifdef _DEBUG
			case 0: case 1: case 2: case 3:
				cout << EM_Hoppa_Noppa << endl;
			break;
#endif
			case 4:
				ll.replace(24,4,tohex(e[2]+256*e[3]));
				ll.replace(28,4,tohex(e[0]+256*e[1]));
			break;
			default:
#ifdef _DEBUG
				if (e.size()&3) cout << EM_Hoppa_Noppa << endl;
#endif
				listfile.push_back(ll);
				string l2;
				int t=0;
				while(1) {
					if( !(t&15) ) { l2=ll.substr(0,24); adr+=16; ll.replace(14,8,tohex(adr,8)); }
					l2+=tohex(e[t+2]+256*e[t+3])+tohex(e[t]+256*e[t+1])+' '; t+=4;
					if( t==e.size() ) { ll=l2; break; }
					if( !(t&15) ) listfile.push_back(l2);
				}
			break;
		}
	}
	listfile.push_back(ll);
}
#endif

void listlistline( int curlin, int page, int adr, string &line, Data &e, string &i ) {
	errtab.geterrors(listcurlin,listfile);
	(*plist)(curlin,page,adr,line,e,i);
	line.clear(); e.clear(); i.clear();
}

void listpool(int curlin, int page, int &adr, Data &e) {
	if (e.empty()) return;
	while (adr&3) ++adr;
	string ll(40,' ');
	ll.replace(0,8,tostr(curlin,8));
	ll.replace(11,2,tohex(page,2));
	ll.replace(14,8,tohex(adr,8));
	ll[13]=':';
	string l2;
	int t=0;
	while(1) {
		if (!(t&15)) { l2=ll.substr(0,24); /*adr+=16;*/ ll.replace(14,8,tohex(adr,8)); }
		l2+=tohex(e[t+2]+256*e[t+3])+tohex(e[t]+256*e[t+1])+' '; t+=4; adr+=4;
		if (t==e.size()) { ll=l2; break; }
		if (!(t&15)) listfile.push_back(l2);
	}
	listfile.push_back(ll);
}

void listlist(SourceList &sl, StringList &pl) {
	listfile.clear();
	listfile.push_back( TXT_Assambler_v + version + " - PipaGerardo      ["+startdate+" - "+starttime+"]" );
	listfile.push_back( TXT_Based_on_Sjasm );
	listfile.push_back("");
	listfile.push_back(sourcefilename);
	listfile.push_back("");
 	listfile.push_back("");
	listfile.push_back( TXT_Line_Pag_Value_Complet );
	listfile.push_back("-----\t--------------\t-----\t\t----------------------------------------------------" );

    // Aqui muestra los errores:
	errtab.geterrors( 0, listfile );

	Data d;
	int eadres=adres,ecurlin=curlin,epage=page;
	string line,info;
	iSourceList isl=sl.begin();
	while (isl!=sl.end()) {
		switch ((*isl)->getlisttype()) {
			case NOLIST: (*isl)->Process(); break;
			case LISTLINE:
				if (!line.empty()) listlistline(ecurlin,epage,eadres,line,d,info);
				(*isl)->Process(); epage=page; eadres=adres; ecurlin=curlin;
				line=(*isl)->listline();
			break;
			case LISTDATA: (*isl)->Process(); d.push((*isl)->listdata()); break;
			case LISTINFO: (*isl)->Process(); if (info.empty()) info=(*isl)->listline(); break;
			case LISTPOOL: (*isl)->Process(); listpool(ecurlin,epage,eadres,(*isl)->listdata()); break;
			default: error( "listlist", ERRINTERNAL );
		}
		++isl;
	}
	if (!line.empty()) listlistline(ecurlin,epage,eadres,line,d,info);
	listfile[4]= TXT_Errors + tostr(errors+adrerrors);

	if( dolistfile ) {
		// if( labellisting ) labtab.listdump( listfile );

		// Aqui peta
	//	printf( "->%s<-\n", listfilename.c_str() );
		WriteFile file( listfilename );
		// Añadido:
        if( !file ) return;

		file.write( listfile );
		if( partlisting ) file.write(pl);
		file.close();
		if( labellisting ) {
			StringList listlab;
			labtab.listdump( listlab );
			WriteFile file( labelfilename );
			file.write( listlab );
			file.close();
		}
	}
}

void outputsymbols() {
	StringList sl;
	labtab.symdump(sl);
	WriteFile file(symfilename);
	file.write(sl);
	file.close();
}

void ListOpt::addlist(SourceList &sl,string line) {
	if( !_list ) {
		if (listopt._macrocurlin!=-1) sl.push_back(new SourceMacroInc());
		return;
	}
	string l;
	switch (_include) {
		case 0:  l="  "; break;
		case 1:  l=". "; break;
		case 2:  l=": "; break;
		case 3:  l=":."; break;
		case 4:  l="::"; break;
		default: l=":>"; break;
	}
	if (!ifstack.empty() && !ifstack.top()._active) l+='~';
	else l+=_char;

	if (_inc) sl.push_back(new SourceListLineInc(l+line));
	else if (listopt._macrocurlin!=-1) sl.push_back(new SourceListLineMacroInc(l+line));
	else sl.push_back(new SourceListLine(l+line));
}

void AdresLabel::Process() {
	int a,p;
	labtab.getvalue(_location,a,p);
	if( (a!=adres/*+_o*/) || p!=page ) labsnok=1;
	_p=page; _a=adres/*+_o*/;
	labtab.setvalue(_location, _a, _p);
}

void NumberLabel::Process() {
	int a;
	numlabtab.getvalue(_index,a);
	if( a!=adres ) labsnok=1;
	numlabtab.setvalue(_index,adres);
}

void FieldLabel::Process() {
	int v,p,val;
	string s=_expr;
	if( !ParseExpression(s, val) ) error( "FieldLabel::Process", ERRINTERNAL );
	labtab.getvalue(_location,v,p);
	if( v!=mapadr || p!=page ) labsnok=1;
	labtab.setvalue(_location, mapadr, page);
	_p=page; _a=mapadr;
	mapadr+=val;
}

void EquLabel::Process() {
	int v, p, val;
	string s=_expr;
	if( !ParseExpression(s, val) ) error( "EquLabel::Process", ERRINTERNAL );
	labtab.getvalue(_location,v,p);
	if( v!=val || p!=page ) labsnok=1;
	labtab.setvalue(_location, val, page);
	_p=page; _a=val;
	// Añadido para evitar el error de etiqueta equ etiqueta
	if( pass>3 && labsnok==1 ) {
		error( EM_Forward_reference, labtab.getname( _location ) );
		labsnok=0;
		return;
	}
}

void SetLabel::Process() {
	int val;
	string s=_expr;
	if( !ParseExpression(s, val) ) error( "SetLabel::Process", ERRINTERNAL );
	labtab.setvalue(_location, val, page, true);
	_p=page; _a=val;
}

void Mnemonic::Process() {
	++lablin;
	if( _funp ) {
		again=0; _e.clear();
		(*_funp)(_line,_e);
		if( !again ) _funp=0;
	}
	output[onr]->emit(_e);
}

void dOrg::Process() {
	string s=_line;
	int val;
	if (ParseExpression(s,val)) adres=val;
	else { error(EM_Expression_expected); return; }
	_listinfo=val;
	checkjunk(s);
	output[onr]->setorg(val);
}

void dRout::Process() {
	_rout->set(_line); output[onr]->setrout(_rnr);
	_a=adres; _p=page; forget=_rout->forget();
}

void dPool::Process() {
	if( !lpass ) return;
	Rout *rn=output[onr]->getroutp();
	IntList &p=rn->getpool();
	for( iIntList i=p.begin(); i!=p.end(); ++i ) {
		_e.push(*i); _e.push(*i>>8); _e.push(*i>>16); _e.push(*i>>24);
	}
}

void dPage::Process() {
	string s=_line;
	getpage(s,pages);
	if (pages.size()==1) {
		_listinfo=pages[0]; _listtype=LISTINFO;
	} else _listtype=NOLIST;
	checkjunk(s);
	_drout.Process();
}

void dMapAlign::Process() {
	string s=_line;
	int val;
	synerr=0;
	if( !ParseExpression(s,val) ) val=4;
	synerr=1;
	// Añadido
	if( val != 0 ) {
		if( mapadr%val ) mapadr+=val-mapadr%val;
	}
	_listinfo=mapadr;
	checkjunk(s);
}

void dMap::Process() {
	string s=_line;
	int val;
// Añadido:
	skipblanks( s );
	if( cneed( s, '@') ) {
		s[0] = ' ';
		skipblanks( s );
		// Si no se ha iniciado un mapa lo iniciamos.
		if( mapadrstack.size() == 0 ) mapadrstack.push(mapadr);
	} else {
// Fin de añadido.
		mapadrstack.push(mapadr);
	}
	if( ParseExpression(s,val) ) mapadr=val;
	else { error(EM_Expression_expected); return; }
	_listinfo=val;
	checkjunk(s);
}

void dEndmap::Process() {
	if( mapadrstack.empty() ) { error(EM_ENDMAP_without_MAP); return; }
	mapadr=mapadrstack.top(); mapadrstack.pop();
	_listinfo=mapadr;
}

void dAlign::Process() {
	string s=_line;
	int val;
	if( !ParseExpression(s,val) ) val=4;
	// Añadido
	if( val != 0 ) {
		if( adres%val ) _listinfo=val-adres%val;
		else _listinfo=0;
	}
	output[onr]->emitblock(0,_listinfo);
	checkjunk(s);
}

void dPhase::Process() {
	string s=_line;
	int val;
	if( !ParseExpression(s,val) ) { error(EM_Expression_expected); return; }
	phaseinfo pi;
	pi._phase=adres-val;
	pi._curlin=curlin;
	pi._listcurlin=listcurlin;
	pi._filename=listopt._filename;
	phasestack.push(pi);
	_listinfo=adres=val;
	checkjunk(s);
}

void dDephase::Process() {
	if (phasestack.empty()) { error(EM_DEPHASE_without_PHASE); return; }
	_listinfo=adres+=phasestack.top()._phase; phasestack.pop();
}

void StartMacro::Process() {
	macstack.push(mac(maclabp,listopt._macroname,listopt._macrofilename,listopt._macrocurlin));
	maclabp=_lab;
	if (pass!=1) {
		listopt._macroname=_name;
		listopt._macrofilename=_file;
		listopt._macrocurlin=_line;
	}
}

void EndMacro::Process() {
//	if (!maclabstack.empty...
	maclabp=macstack.top()._maclabp;
	if (pass!=1) {
		listopt._macroname=macstack.top()._name;
		listopt._macrofilename=macstack.top()._file;
		listopt._macrocurlin=macstack.top()._line;
	}
	macstack.pop();
}

void SetModule::Process() {
	modlabp=_lab;
}

void SetListOpt::Process() {
	listopt=_listopt;
	curlin=listopt._curlin;
}

void piDS::Process() {
	string s=_line;
	int val;
	if( ParseExpression(s,val) ) _n=val;
	else {
		error(EM_Expression_expected); return;
	}
	if (comma(s)) {
		if (ParseExpression(s,val)) _b=val;
		else {
			error(EM_Expression_expected); return;
		}
	} else _b=0;
	if( _n<0 ) { error(EM_Negative_block_notallowed,ERRLPASS); return; }
	if( _n ) output[onr]->emitblock(_b,_n);
	checkjunk(s);
}

dIncbin::dIncbin(std::string n_line, bool list) : _line(n_line),_listinfo(0) {
	ListOpt olistopt=listopt;
	string n;
	ReadFile file( getpath(n=getfilename(_line)) );
	if( file.ok() ) {
		byte *buffer; int size;
		file.getbuffer( buffer,size );
		_data.setdata( buffer,size );
	} else {
		_data.clear();
		error(EM_Syntax_error,ERRREP);
	}
	if( list )	_listtype=LISTDATA;
	else		_listtype=LISTINFO;
	listopt=olistopt;
}

void dIncbin::Process() {
	if (_data.empty()) return;
	string s=_line;
	int offset=0,length=_data.size(),val;
	if( comma(s) ) {
		switch (comma(s)) {
			case false:
				if (ParseExpression(s,val)) {
					offset=val; length-=offset;
				} else { error(EM_Expression_expected,ERRREP); return; }
				if (!comma(s)) break;
			case true:
				if (ParseExpression(s,val)) length=val;
				else { error(EM_Expression_expected,ERRREP); return; }
			break;
		}
	}
	checkjunk(s);
	if( offset<0 ) { offset=0; error(EM_Negative_offsetnotallowed); }
	if( length<0 ) { length=0; error(EM_Negative_lengthnotallowed); }
	if( offset+length>_data.size() ) { error(EM_file_size_not_allowed); return; }
	_e.setdata( _data.getdatap(offset), length );
	output[onr]->emit(_e);
	_listinfo=length;
}

Data &dIncbin::listdata() {
	return _e;
}

void SetOutput::Process() {
	setoutput(_onr);
}

void StructExp::Process() {
	_e.clear();
	structtab.get(_structure)->emitdata(_line,_e,_label);
	output[onr]->emit(_e);
}

void Repeat::Process() {
	string s=_count;
	_e.clear();
	int c, i=0, olablin=lablin;
	if( ParseExpression(s,c) ) {
		if( c<0 ) error( EM_Negative_repeat_count );
		else {
			while (c--) {
				repeatstack.push_back(i);
				_sn->Process();
				repeatstack.pop_back();
				_e.push(_sn->listdata());
				++i;
			}
		}
	} else error( EM_Syntax_error );
	lablin=olablin+1;
}

void dAssert::Process() {
	if( lpass ) {
		string s=_line;
		int v=0;
		if( ParseExpression( s, v ) ) {
			if( !v ) error( EM_Assertion_failed,_line );
		} else error( EM_Expression_expected );
	}
}

//eof

