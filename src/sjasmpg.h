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

// sjasmpg.h

#ifndef _SJASMPG_SJASM_
#define _SJASMPG_SJASM_

// --------------------------------
//      * * * VERSION * * *
// --------------------------------
#define VERSION_NUM	"0.1.0.1"
#define VERSION_STR	"0.1.0.1"
// --------------------------------

// --------------------------------
//      * * * INFORMACION * * *
// --------------------------------
// Linker Settings:
//      -static-libgcc
//      -static-libstdc++
//
//  #define WINDOWS         //
//  #define LINUX           //
//  #define APPLE           //
//	#define SPANISH         // Idioma en Español
//  #define LANGUAGE_UTF8   // Idioma en Español para Linux y Apple
//	#define _DEBUG          // Modo depuración
//	#define EXAMPLE_ASM     // En depuración carga un ejmemplo
//	#define METARM          // Ni idea...
// --------------------------------

#ifdef WINDOWS
#define SLASH '\\'
#define BADSLASH '/'
#define NEWLINE "\r\n"
#else
#define SLASH '/'
#define BADSLASH '\\'
#define NEWLINE "\n"
#endif

#include <time.h>
#include <list>
#include <stack>
#include <vector>
#include <sstream>
#include <iostream>
#include <cstring>	// Añadido para usar memset
#include <cstdlib>	// Añadido apara usar abs
// ----------------------------------------------------------------------------
using namespace std;
const int BIGVALUE = 2147483647; // :p
// ----------------------------------------------------------------------------
struct Options {
	Options() :
		listloops(false),
		listmacros(true),
		onlybp(true),		// only [] for indirections
		useldradr(true),
		usemovlsl(true),
		allpages(false),
		optimizejumps(false) {
	}
	bool listloops;
	bool listmacros;
	bool onlybp;			// only [] for indirections, no ()               MSX
	bool useldradr;			// use ldr when add/sub does not work with adr   ARM
	bool usemovlsl;			// use mov\lsl if possible with ldr              ARM
	bool allpages;			// must all pages exist?
	bool optimizejumps;		// convert jumps (jp/jr/djnz)                    MSX
	bool listbincludes;
};
// ----------------------------------------------------------------------------
// sjasm.cpp
// extern string expfilename;
extern Options options, defaultoptions;
extern string starttime, startdate, sourcefilename, destfilename, listfilename, symfilename, printfilename, labelfilename;
extern int listcurlin, adres, page, pass, labsnok, mapadr, synerr, again;
extern int labelnotfound, macronummer, unieknummer, curlin;
extern int lpass, errors, adrerrors, symfile, dolistfile, labellisting, partlisting, lablin;
extern char tobuffer[64];
extern string maclabp, vorlabp, modlabp, version;
extern vector<string> cmdparameter;
// ----------------------------------------------------------------------------
class Rout;	// output.h
#include "datastructures.h"
// ----------------------------------------------------------------------------
// dataestructures.h  -> preprocessor.cpp
extern DefineTable		deftab;
extern DefineArgTable	defargtab;
extern MacNumTable		macnumtab;
extern MacroTable		mactab;
extern StructTable		structtab;
extern FunctionTable<pFun,RawSource> group1iftab, group2iftab, group1tab, group2tab;
// ----------------------------------------------------------------------------
// dataestructures.h  -> sjasm.cpp
extern LabelTable		labtab;
extern NumLabelTable	numlabtab;
// ----------------------------------------------------------------------------
// dataestructures.h  -> datadir.cpp
extern FunctionTable< pFun, RawSource > datafuntab;
// ----------------------------------------------------------------------------
// dataestructures.h  -> directives.cpp
extern FunctionTable< pFun, RawSource > dirfuntab;
// ----------------------------------------------------------------------------
#include "fileio.h"
// fileio.h	-> fileio.cpp
extern StringList paths;
// ----------------------------------------------------------------------------
#include "reader.h"
// expressions.h	-> expressions.cpp
extern Find findlabelchar;
// ----------------------------------------------------------------------------
#include "datadir.h"
// ----------------------------------------------------------------------------
#include "preprocessor.h"
extern stack<ifinfo> ifstack;
extern Stop stop;
// ----------------------------------------------------------------------------
#include "source.h"
// source.h	-> source.cpp
extern stack< phaseinfo > phasestack;
extern vector< int > repeatstack;
// typedef void (*pListMode)(int,int,int,string&,Data&,string&);
// extern pListMode plist;
// extern ListOpt listopt;
// ----------------------------------------------------------------------------
extern void error(string,int);
extern Rout *routlabel;
#include "output.h"
// ----------------------------------------------------------------------------
#include "rawsource.h"
#include "expressions.h"
#include "directives.h"
// ----------------------------------------------------------------------------
#include "errors.h"
// errors.h	-> errors.cpp
extern ErrorTable errtab;
// ----------------------------------------------------------------------------
#include "pimsx.h"
#ifdef METARM
#include "pithumb.h"
#include "piarm.h"
#endif
// ----------------------------------------------------------------------------
// error.h	->	errors.cpp
extern ErrorTable errtab;

// Generic:
/*
extern string EM_Syntax_error;
extern string EM_Overflow;
extern string EM_Hoppa_Noppa;
extern string EM_Illegal_operand;
extern string EM_Illegal_parameter;
extern string EM_Illegal_range;
extern string EM_Unknown_instruction;
extern string EM_Forward_reference;
extern string EM_Expression_expected;
extern string EM_Parameter_missing;
extern string EM_Operand_expected;
extern string EM_Division_by_zero;
// Size:
extern string EM_Too_much_data;
extern string EM_Negative_size;
extern string EM_Size_expected;
extern string EM_Size_already_set;
extern string EM_Maximum_part_size_256;
extern string EM_Part_does_not_fit;
// Logic:
extern string EM_Unexpected;
extern string EM_Base_expected;
extern string EM_Increment_expected;
extern string EM_Cannot_negate_condition;
extern string EM_Negative_origin;
extern string EM_Digit_not_in_base;
extern string EM_No_default_allowed;
extern string EM_No_greedy_stars_allowed;
// Closing:
extern string EM_No_closing_B;
extern string EM_No_closing_R;
extern string EM_Closing_P_expected;
extern string EM_Closing_C_expected;
// Value / Target:
extern string EM_Default_value_expected;
extern string EM_Value_out_of_range;
extern string EM_Target_out_of_range;
// Over:
extern string EM_Overlay_code_part_needs;
extern string EM_Overlapping_routines;
extern string EM_Overloading_not_allowed;
// String:
extern string EM_String_expected;
extern string EM_Unexpected_end_of_string;
extern string EM_Empty_string_not_allowed;
extern string EM_Constant_expected;
// Chars:
extern string EM_Illegal_character;
extern string EM_Character_range_expected;
extern string EM_Comma_expected;
extern string EM_Unknown_escape;
// Label:
extern string EM_Illegal_label_name;
extern string EM_Label_not_found;
extern string EM_Duplicate_labelname;
extern string EM_Label_already_exists;
extern string EM_Mixing_set_normal_labels;
extern string EM_Numberlabels_only_allowed;
// Macro:
extern string EM_Illegal_macroname;
extern string EM_Illegal_macro_definition;
extern string EM_Macro_already_exists;
extern string EM_Indirection_not_allowed;
extern string EM_Use_rotate_outside_macro;
extern string EM_Use_num_outside_macro;
extern string EM_Use_num_outside_loops;
extern string EM_ENDMACRO_without_MACRO;
extern string EM_EXITMACRO_outside_macro;
extern string EM_XEXITMACRO_outside_macro;
// Struct:
extern string EM_Illegal_structure_name;
extern string EM_Label_structure_not_found;
extern string EM_Structure_already_exists;
extern string EM_ENDSTRUCT_without_STRUCT;
// Offest / Address / Align:
extern string EM_Invalid_addressrange;
extern string EM_Illegal_addressmode;
extern string EM_Illegal_alignment;
extern string EM_Offset_expected;
extern string EM_Offsets_not_allowed_jumps;
extern string EM_Offset_out_of_range;
extern string EM_Alignment_expected;
extern string EM_Alignment_value_expected;
extern string EM_Alignment_shouldbepositiv;
extern string EM_Unknown_alignmode;
extern string EM_Negative_zero_alignment;
extern string EM_Negative_block_notallowed;
extern string EM_Negative_offsetnotallowed;
extern string EM_Negative_lengthnotallowed;
extern string EM_file_size_not_allowed;
extern string EM_Assertion_failed;
// Defines:
extern string EM_Illegal_define_name;
extern string EM_ReplaceDefines;
extern string EM_Redefinition_multiparamet;
extern string EM_Cant_undef_a_define_with;
// Page:
extern string EM_Illegal_pagenumber;
extern string EM_Invalid_pagerange;
extern string EM_Page_already_exists;
extern string EM_Page_does_not_exist;
extern string EM_Unknown_multipagemode;
// Module:
extern string EM_ENDMODULE_without_MODULE;
extern string EM_MODULE_not_found;
// BUCLES IF ELSE WHILE:
extern string EM_IF_without_ENDIF;
extern string EM_ELSEIF_without_IF;
extern string EM_ELSEIF_within_ELSE;
extern string EM_ELSE_without_IF;
extern string EM_ELSE_within_ELSE;
extern string EM_ENDIF_without_IF;
extern string EM_ENDWHILE_without_WHILE;
extern string EM_ENDREPEAT_without_REPEAT;
extern string EM_BREAK_used_outside_loop;
extern string EM_CONTINUE_outside_loop;
extern string EM_Negative_repeat_value;
extern string EM_Negative_repeat_count;
extern string EM_Nothing_to_repeat;
extern string EM_without_repeatblock;
// CODE / MAP / PHASE:
extern string EM_CODE_not_allowed_in_PHASE;
extern string EM_ENDMAP_without_MAP;
extern string EM_PHASE_without_PHASE;
extern string EM_DEPHASE_without_PHASE;
// File:
extern string EM_Error_opening_file;
extern string EM_Write_error;
extern string EM_Unexpected_end_of_file;
extern string EM_No_inputfile;
*/

// ----------------------------------------------------------------------------
// source.cpp
extern stack<int> mapadrstack;
extern stack<string> modulestack;
// ----------------------------------------------------------------------------
// dataestructures.h  -> sjasm.cpp
extern IntList pages;
// ----------------------------------------------------------------------------
// sjasm.cpp = rawsource.h  -> source.h
extern void (*piCPU)(string&,SourceList*);
// ----------------------------------------------------------------------------
// output.h		-> output.cpp
extern vector<Output*> output;
extern int onr;
// ----------------------------------------------------------------------------
#endif
//eof
