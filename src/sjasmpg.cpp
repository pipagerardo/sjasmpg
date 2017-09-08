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

#include "sjasmpg.h"

#ifdef LANGUAGE_UTF8
#include "language_utf8.h"
#else
#include "language_iso.h"
#endif

// #include <clocale>
#include <locale.h>
// #include <cstdio>

Options options;

string version=VERSION_STR;
string starttime, startdate, sourcefilename, destfilename, listfilename, symfilename, printfilename, labelfilename;

int listcurlin, adres, page, pass, labsnok, mapadr, synerr, again, labelnotfound, macronummer=0, unieknummer=0, curlin, lablin;
int lpass=0, errors=0, adrerrors=0, symfile=0, dolistfile=1, labellisting=1, partlisting=1;
char tobuffer[64];

IntList pages;
LabelTable labtab;
NumLabelTable numlabtab;
vector<string> cmdparameter;

void (*piCPU)( string&, SourceList* );

string maclabp,vorlabp,modlabp;

void initpass() {
	listopt.init();
	++pass;
	onr=0;
	listcurlin=0;
	curlin=0;
	adres=0;
	page=0;
	pages.clear();
	pages.push_back(page);
	mapadr=0;
	labsnok=0;
	synerr=1;
	lablin=0;
	maclabp="";
	vorlabp="_";
	modlabp="";
	piCPU=pimsx;
//  plist=listlistlinez80;
	while( !modulestack.empty() ) modulestack.pop();
	while( !mapadrstack.empty() ) mapadrstack.pop();
	resetoutput();
	numlabtab.resetindex();
	routlabel=0;
}

void endpass() {
	ListOpt olistopt=listopt;
	while( !phasestack.empty() ) {
		listopt._filename=phasestack.top()._filename;
		error(
			phasestack.top()._curlin,
			phasestack.top()._listcurlin,
			EM_PHASE_without_PHASE,
			""
		);
	phasestack.pop();
	}
	while( !ifstack.empty() ) {
		listopt._filename=ifstack.top()._filename;
		error(
			ifstack.top()._curlin,
			ifstack.top()._listcurlin,
			EM_IF_without_ENDIF,
			""
		);
		ifstack.pop();
	}
	listopt=olistopt;
}

void getoptions( char **&argv, int &i ) {
	char *p, c;
	while( argv[i] && *argv[i]=='-' ) {
		p=argv[i++]+1;
		do {
			c=*p++;
			switch( tolower(c) ) {
				case 'q': dolistfile=0; break;
				case 's': symfile=1; break;
				case 'i': paths.push_back(p); p=(char*)""; break;
				case 'j': options.optimizejumps=true; break;
				case 'p': options.onlybp=false; break;
				default:
					cout << TXT_Unrecognised_option  << c << endl;
				break;
			}
		} while (*p);
	}
}

string makefilename( string &fn, string ext ) {
	int p=(int)fn.find_last_of('.');
	if( p==(int)string::npos )	return fn+ext;
	else 						return fn.substr(0,p)+ext;
}


#ifdef WINDOWS
//    #include lo_que_sea
#endif

#ifdef LINUX
//    #include lo_que_sea
#endif

#ifdef APPLE
/*
	#include "CoreFoundation/CoreFoundation.h"
	// link: libCoreFoundation.so
*/
#endif

int main( int argc, char *argv[] ) {

#ifdef APPLE
/*
{
    // En principio esto no es requerido en MAC, pero por si acacaso:

    // Returns an application’s main bundle:
    // CFBundleRef CFBundleGetMainBundle( void );
    CFBundleRef mainBundle = CFBundleGetMainBundle();

    // Returns the location of a bundle’s Resources directory:
    // CFURLRef CFBundleCopyResourcesDirectoryURL( CFBundleRef bundle );
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL( mainBundle );

    // Fills a buffer with the file system's native string representation of a given URL's path:
    // bool CFURLGetFileSystemRepresentation(
    //      url,                // The CFURL object whose native file system representation you want to obtain.
    //      resolveAgainstBase, // Pass true to return an absolute path name.
    //      buffer,             // A pointer to a character buffer. On return, the buffer holds the native file
    //                          // system's representation of url. The buffer is null-terminated.
    //                          // This parameter must be at least maxBufLen in size for the file system in
    //                          // question to avoid failures for insufficiently large buffers.
    //      maxBufLen           // The maximum number of characters that can be written to buffer.
    // );
   	char path[1024];
   	if( !CFURLGetFileSystemRepresentation( resourcesURL, TRUE, (UInt8 *)path, PATH_MAX ) ) return -1;

    // Releases a Core Foundation object:
    // void CFRelease( CFTypeRef cf );
   	CFRelease( resourcesURL );

   	// Vhange working directory:
   	// #include <unistd.h>
   	// int chdir( const char *path );
   	chdir( path );
}
*/
#endif

#ifdef SPANISH
// SPANISH:
#ifdef LANGUAGE_UTF8
    setlocale( LC_ALL, "es_ES.UTF-8" );
#else
    setlocale( LC_ALL, ".ACP" );
#endif
#else
// ENGLISH:
    setlocale( LC_ALL, "C" );
#endif

	cout << TXT_Assambler_v << version << " - PipaGerardo\n";
	cout << TXT_Based_on_Sjasm ;

#ifdef EXAMPLE_ASM
	sourcefilename="ejemplo/src/ejemplo.asm";
	destfilename  ="ejemplo/ejemplo.rom";
	paths.push_back( "ejemplo" );
    symfile=1;
#else
	if( argc==1 ) {
		cout << TXT_OPTION_01;
		cout << TXT_OPTION_02;
		cout << TXT_OPTION_03;
		cout << TXT_OPTION_04;
		cout << TXT_OPTION_05;
		cout << TXT_OPTION_06;
		cout << TXT_OPTION_07;
		exit(1);
	}
	int i=1, p;
	getoptions( argv, i );
	if( argv[i] ) sourcefilename = argv[i++];
	if( argv[i] ) destfilename   = argv[i++];
	p=10;
	while( p-- ) cmdparameter.push_back(" ");
	p=1;
	while( argv[i] && p<10 ) cmdparameter[p++] = argv[i++];
	if( argv[i] ) error( TXT_Too_many_command_line_para );
#endif

	// Si no hay archivo fuente nos salimos:
	if( !sourcefilename[0] ) { 	// string
		cout << EM_No_inputfile << endl;
		exit(1);
	}

	// Si no hay archivo de destino lo creamos:
	if( !destfilename[0] ) {
        destfilename=makefilename( sourcefilename, ".out" );
	}

	// Creamos el resto de archivos auxiliares:
	listfilename =makefilename( destfilename,"_lst.txt" );	    // Listado informativo
	labelfilename=makefilename( destfilename,"_lab.txt" );      // Etiquetas
	symfilename  =makefilename( destfilename,".sym" );	        // Debug BlueMSX
	printfilename=makefilename( destfilename,"_print.txt" );	// printstr, printdec, printhex
//	expfilename  =makefilename( destfilename,".exp" );	        // ???

	initpreprocessor();		// IF, MACRO, INCLUDE, ETC...
	initPidata();			// DB, DW, ETC...
	initDir();				// MODULE, PAGE, CODE, ETC...
	initPiMSX();			// Instrucciones del Z80
#ifdef METARM
	initPiThumb();			// "thumb" -> dirTHUMB
	initPiArm();			// "arm" -> dirARM
#endif

	// Toma el tiempo del sistema y lo formatea en string starttime y startdate:
	time_t st=time(0);
	strftime( tobuffer,64,"%H:%M:%S",localtime(&st) ); starttime=tobuffer;
	strftime( tobuffer,64,"%Y.%m.%d",localtime(&st) ); startdate=tobuffer;

	pass=0;
	initpass();
	output.push_back( new Output( destfilename ) );
	RawSource *rawsource=new RawSource( sourcefilename );
	rawsource->GetSource().push_back( new dPool() );
	endpass();
	sortoutput();

	// pass 0, 1 y 2
	do {
		initpass();
		process( rawsource->GetSource() );
		endpass();      // stack<phaseinfo> phasestack;
		sortoutput();	// Ordena vector<Output*> output;
//	} while( pass<3 || (labsnok && !errors ));
	} while( (pass<3 || labsnok ) && !errors );

	StringList dump;
	if( partlisting ) dumpoutput( dump );

	printOutput();

	// Crea el archivo de salida ".rom" destfilename:
	if( ( errors + adrerrors ) == 0 ) {
		saveoutput();
	}

	// Creamos el archivo ".lst" Listado informativo
	initpass();
	lpass=1;

    //----------------------------------------------------------
	listlist( rawsource->GetSource(), dump );
    //----------------------------------------------------------

	if( ( errors + adrerrors ) == 0 ) {
	// Creamos el archivo sym parar depurar con BlueMSX
		if( symfile ) outputsymbols();
	} // else {
	// Borramos los archivos de salida fallidos:
		// remove( destfilename.c_str() );
		// remove( listfilename.c_str() );
//	}

//  getchar();

	return ( errors + adrerrors ) != 0;

}

//eof

