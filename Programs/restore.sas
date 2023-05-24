************************************************************************
* Name: restore.sas                                                    *
* Description: Restore options changed by autoexec                     *
* Creation Date: 24/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;





*------ Do not unintentionally edit below this line ------------------------------------------------------------;

/* Restore changed settings in autoexec.sas */
* Output information;
options msglevel=&msglevel.;
* Formats found in shared file;
options fmtsearch=&fmtsearch.;
* Turning on autocorrect for safety;
options autocorrect;