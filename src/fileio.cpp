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

// fileio.cpp
#include "sjasmpg.h"
// #include "fileio.h"

#ifdef LANGUAGE_UTF8
#include "language_utf8.h"
#else
#include "language_iso.h"
#endif

StringList paths;

string fileexists( string npath, string filename ) {
	string np;
	if (filename[0]==SLASH) np=filename;
	else {
		np=npath;
		if( !np.empty() && np[np.size()-1] != SLASH ) np+=SLASH;
		np+=filename;
	}
	FILE *f=fopen(np.c_str(),"r");
	if (f) fclose(f);
	if (f) return np;
	else return "";
}

string getpath( string &filename ) {
	string np;
	np=fileexists(listopt._path,filename);
	if (np.empty()) {
		sbcneed(filename,'<');
		for (iStringList i=paths.begin(); i!=paths.end(); ++i) {
			np=fileexists(*i,filename);
			if (!np.empty()) break;
		}
	}
	if (np.empty()) np=fileexists(listopt._path,filename);
	if (np.empty()) {
		np=listopt._path;
		 if (!np.empty() && np[np.size()-1]!=SLASH) np+=SLASH;
		 np+=filename;
	}
	int pos=(int)np.find_last_of(SLASH);
	if (pos==(int)string::npos) { listopt._path.clear(); return filename; }
	listopt._path=np.substr(0,pos);
	return np;
}

string getfilename( string &p ) {
	int pos=0;
	string res;
	if (sbcneed(p,'"')) {
		res=p.substr(0,pos=(int)p.find_first_of('"'));
		if (pos==(int)string::npos) error1(EM_No_closing_B);
		else ++pos;
	} else if (p[0]=='<') {
		res=p.substr(0,pos=(int)p.find_first_of('>'));
		if (pos==(int)string::npos) error1(EM_No_closing_R);
		else ++pos;
	} else {
		res=p.substr(0,pos=(int)p.find_first_of(','));
	}
	if (pos==(int)string::npos) p.clear();
	else p=p.substr(pos);
	for (istring i=res.begin(); i!=res.end(); ++i) if (*i==BADSLASH) *i=SLASH;
	return res;
}

ReadFile::ReadFile( string n_name ) : _buffer(0) {
	FILE *file;
	if ((file=fopen(n_name.c_str(),"rb"))==NULL) {
		error1(EM_Error_opening_file,n_name); return;
	}
	fseek(file,0,SEEK_END); _size=ftell(file); fseek(file,0,SEEK_SET);
	_buffer=new unsigned char[_size+1];
	if (fread(_buffer,_size,1,file)) _buffer[_size]=0;
	else { _buffer=0; error1(EM_Error_opening_file,n_name); }
	fclose(file);
}

ReadFile::~ReadFile() {
	delete [] _buffer;
}

void ReadFile::readtostringlist( StringList &sl ) {
	char *ls,*le;
	ls=le=(char *)_buffer;
	while (*le) {
		switch (*le) {
			case 10: *le++=0; if (*le==13) ++le; sl.push_back(ls); ls=le; break;
			case 13: *le++=0; if (*le==10) ++le; sl.push_back(ls); ls=le; break;
			default: ++le; break;
		}
	}
	if (ls!=le) sl.push_back(ls);
}

WriteFile::WriteFile( string name, FILEMODE n_mode ) {
	_mode=n_mode;
	if (_mode==UPDATE && fileexists("",name).empty()) _mode=OVERWRITE;

    _file = NULL;
	_file=fopen( name.c_str(), _mode==OVERWRITE ? "wb" : "rb+" );
// Añadido para que no pete:
	if( _file == NULL ) {
        error( EM_Error_opening_file, name );
        return;
    }

	fseek( _file, 0, SEEK_SET );
	if (!_file) { error(EM_Error_opening_file,name); return; }
}

WriteFile::~WriteFile() {
    close();
}

void WriteFile::write( Data &e ){
    if( _file == NULL ) return;
	_buffer.push(e);
}

void WriteFile::write( StringList &sl ) {
    if( _file == NULL ) return;
	for (iStringList isl=sl.begin(); isl!=sl.end(); ++isl) {
		fputs(isl->c_str(),_file);
		fputs(NEWLINE,_file);
	}
}

void WriteFile::write( string &s ) {
    if( _file == NULL ) return;
	fputs( s.c_str(), _file );
}

void WriteFile::skip( int len ){
    if( _file == NULL ) return;
	if (_mode==OVERWRITE) {
		while (len--) _buffer.push(0);
	} else {
		_writebuf();
		fseek(_file,len,SEEK_CUR);
	}
}

void WriteFile::close() {
    _writebuf();
    if( _file != NULL ) {
        fclose(_file);
        _file = NULL;
    }
}

bool WriteFile::ok() { return _file!=NULL; }

bool WriteFile::operator !() {
    return (_file == NULL) ? true : false;
}

void WriteFile::_writebuf() {
    if( _file != NULL ) {
        if( _buffer.size() ) {
            if( (int)fwrite( _buffer.getdatap(), 1, _buffer.size(), _file ) < _buffer.size() )
                error( EM_Write_error, ERRFATAL );
        }
	}
	_buffer.clear();
}

//eof
