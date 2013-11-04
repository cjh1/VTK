
/*=========================================================================

  Program:   Visualization Toolkit
  Module:    vtkRCalculatorFilter.h

  Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen
  All rights reserved.
  See Copyright.txt or http://www.kitware.com/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notice for more information.

=========================================================================*/
/*-------------------------------------------------------------------------
  Copyright 2009 Sandia Corporation.
  Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
  the U.S. Government retains certain rights in this software.
-------------------------------------------------------------------------*/

// .NAME vtkRCalculatorFilter
//
// .SECTION Description
//
// This class functions as an array calculator for vtkDataArrays and VTKarray objects,
// using GNU R as the calculation engine.
//
// .SECTION See Also
//  vtkRInterface vtkRadapter
//
// .SECTION Thanks
//  Developed by Thomas Otahal at Sandia National Laboratories.
//

#ifndef __vtkRCalculatorFilter_h
#define __vtkRCalculatorFilter_h

#include "vtkFiltersStatisticsGnuRModule.h" // For export macro
#include "vtkDataObjectAlgorithm.h"
#include <string>

class vtkRInterface;
class vtkRCalculatorFilterInternals;
class vtkDataSet;
class vtkDoubleArray;
class vtkGraph;
class vtkTree;
class vtkTable;
class vtkCompositeDataSet;
class vtkArrayData;
class vtkStringArray;

class VTKFILTERSSTATISTICSGNUR_EXPORT vtkRCalculatorFilter : public vtkDataObjectAlgorithm
{

public:

  static vtkRCalculatorFilter *New();

  vtkTypeMacro(vtkRCalculatorFilter, vtkDataObjectAlgorithm );
  void PrintSelf(ostream& os, vtkIndent indent);

  // Description:
  // Copies vtkDataArray named NameOfVTKArray to R with variable
  // name NameOfRvar.  The array must exist in the input data set.
  //
  // Note: for vtkArray use "0","1","2",... for NameOfVTKArray to specify the index of
  // the vtkArray to pass to R.
  void PutArray(const char* NameOfVTKArray, const char* NameOfRvar);

  // Description:
  // Copies R variable NameOfRvar from R to the vtkDataArray named
  // NameOfVTKArray.  Will replace existing vtkDataArray with the same name.
  //
  // Note: for vtkArray use any string for NameOfVTKArray.  The array will be appended
  // to the list of vtkArrays on the output.
  void GetArray(const char* NameOfVTKArray, const char* NameOfRvar);

  // Description:
  // Clears the list of variables to be copied to R.
  void RemoveAllPutVariables();

  // Description:
  // Clears the list of variables to be copied from R.
  void RemoveAllGetVariables();

  // Description:
  // For vtkTable input to the filter.  An R list variable is created for the
  // vtkTable input using PutTable().  The output of the filter can be set from
  // a list variable in R using GetTable()
  void PutTable(const char* NameOfRvar);
  void GetTable(const char* NameOfRvar);

  // Description:
  // TODO
  void PutTables(vtkStringArray* NamesOfRVars);
  void GetTables(vtkStringArray* NamesOfRVars);

  // Description:
  // For vtkTree input to the filter.  An R phylo tree variable is created for the
  // vtkTree input using PutTree().  The output of the filter can be set from
  // a phylo tree variable in R using GetTree()
  void PutTree(const char* NameOfRvar);
  void GetTree(const char* NameOfRvar);

  // Description:
  // TODO
  void PutTrees(vtkStringArray* NamesOfRvars);
  void GetTrees(vtkStringArray* NamesOfRvars);


  // Description:
  // Script executed by R.  Can also be set from a file.
  vtkSetStringMacro(Rscript);
  vtkGetStringMacro(Rscript);

  // Description:
  // Provide the R script executed by R from an input file.
  vtkSetStringMacro(ScriptFname);
  vtkGetStringMacro(ScriptFname);

  // Description:
  // Write R output to standard output.
  vtkSetMacro(Routput,int);
  vtkGetMacro(Routput,int);

  // Description:
  // Pass VTK time information to R.
  // If turned turned on, the filter will create three variables in R.
  // The variables will be update automatically as time
  // changes in the VTK pipeline.
  // VTK_TIME_STEPS - array of all available time values.
  // VTK_TIME_RANGE- array of minimum and maximum time values.
  // VTK_CURRENT_TIME - floating point time value at the current time index.
  vtkSetMacro(TimeOutput,int);
  vtkGetMacro(TimeOutput,int);

  // Description:
  // Create VTK_BLOCK_ID variable in R when processing composite data sets.
  vtkSetMacro(BlockInfoOutput,int);
  vtkGetMacro(BlockInfoOutput,int);

  // Description:
  // This is required to capture REQUEST_DATA_OBJECT requests.
  virtual int ProcessRequest(vtkInformation* request,
                             vtkInformationVector** inputVector,
                             vtkInformationVector* outputVector);

protected:

  int SetRscriptFromFile(const char* fname);

  virtual int RequestData(vtkInformation *vtkNotUsed(request),
                          vtkInformationVector **inputVector,
                          vtkInformationVector *outputVector);

  // Description:
  // Creates the same output type as the input type.
  virtual int RequestDataObject(vtkInformation* request,
                                vtkInformationVector** inputVector,
                                vtkInformationVector* outputVector);

  vtkRCalculatorFilter();
  ~vtkRCalculatorFilter();

private:

  vtkRCalculatorFilter(const vtkRCalculatorFilter&);  // Not implemented.
  void operator=(const vtkRCalculatorFilter&);  // Not implemented.

  // Implementation details
  vtkRCalculatorFilterInternals* rcfi;

  int ProcessInputDataSet(vtkDataSet* dsIn);
  int ProcessOutputDataSet(vtkDataSet* dsOut);

  int ProcessInputGraph(vtkGraph* gIn);
  int ProcessOutputGraph(vtkGraph* gOut);

  int ProcessInputArrayData(vtkArrayData * adIn);
  int ProcessOutputArrayData(vtkArrayData * adOut);

  int ProcessInputCompositeDataSet(vtkCompositeDataSet* cdsIn);
  int ProcessOutputCompositeDataSet(vtkCompositeDataSet * cdsOut);

  int ProcessInputTable(vtkTable* tOut);
  int ProcessInputTable(std::string& name, vtkTable* tIn);

  vtkTable* GetOutputTable(std::string& name);
  int ProcessOutputTable(vtkTable* tOut);
  int ProcessOutputTable(int nameIndex, vtkTable* tOut);

  int ProcessInputTree(vtkTree* tIn);
  int ProcessInputTree(std::string& name, vtkTree* tIn);

  vtkTree* GetOutputTree(std::string& name);
  int ProcessOutputTree(vtkTree* tOut);
  int ProcessOutputTree(int nameIndex, vtkTree* tOut);

  int ProcessInputDataObject(vtkDataObject *input);
  int ProcessOutputDataObject(vtkDataObject *input);
  int HasMultipleGets();
  int HasMultiplePuts();
  int IsAsymmetric();

  vtkRInterface* ri;
  char* Rscript;
  char* RfileScript;
  char* ScriptFname;
  int Routput;
  int TimeOutput;
  int BlockInfoOutput;
  char* OutputBuffer;
  vtkDoubleArray* CurrentTime;
  vtkDoubleArray* TimeRange;
  vtkDoubleArray* TimeSteps;
  vtkDoubleArray* BlockId;
  vtkDoubleArray* NumBlocks;

};

#endif

