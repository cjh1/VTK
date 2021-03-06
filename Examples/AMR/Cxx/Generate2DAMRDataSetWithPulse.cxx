/*=========================================================================

  Program:   Visualization Toolkit
  Module:    Generate2DAMRDataSetWithPulse.cxx

  Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen
  All rights reserved.
  See Copyright.txt or http://www.kitware.com/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notice for more information.

=========================================================================*/
// .NAME Generate2DAMRDataSetWithPulse.cxx -- Generates sample 2-D AMR dataset
//
// .SECTION Description
//  This utility code generates a simple 2D AMR dataset with a gaussian
//  pulse at the center. The resulting AMR dataset is written using the
//  vtkXMLHierarchicalBoxDataSetWriter.

#include <iostream>
#include <cmath>
#include <sstream>
#include <cassert>

#include "vtkUniformGrid.h"
#include "vtkDataArray.h"
#include "vtkDoubleArray.h"
#include "vtkCell.h"
#include "vtkPoints.h"
#include "vtkPointData.h"
#include "vtkCellData.h"
#include "vtkAMRBox.h"
#include "vtkHierarchicalBoxDataSet.h"
#include "vtkXMLHierarchicalBoxDataWriter.h"
#include "vtkAMRUtilities.h"
#include "AMRCommon.h"

struct PulseAttributes {
  double origin[3]; // xyz for the center of the pulse
  double width[3];  // the width of the pulse
  double amplitude; // the amplitude of the pulse
} Pulse;

//
// Function prototype declarations
//

// Description:
// Sets the pulse attributes
void SetPulse();

// Description:
// Constructs the vtkHierarchicalBoxDataSet.
vtkHierarchicalBoxDataSet* GetAMRDataSet();

// Description:
// Attaches the pulse to the given grid.
void AttachPulseToGrid( vtkUniformGrid *grid );

//
// Program main
//
int main( int argc, char **argv )
{
  // Fix compiler warning for unused variables
  static_cast<void>(argc);
  static_cast<void>(argv);

  // STEP 0: Initialize gaussian pulse parameters
  SetPulse();

  // STEP 1: Get the AMR dataset
  vtkHierarchicalBoxDataSet *amrDataSet = GetAMRDataSet();
  assert( "pre: NULL AMR dataset" && ( amrDataSet != NULL ) );

  AMRCommon::WriteAMRData( amrDataSet, "Gaussian2D" );
  amrDataSet->Delete();
  return 0;
}

//=============================================================================
//                    Function Prototype Implementation
//=============================================================================

void SetPulse()
{
  Pulse.origin[0] = Pulse.origin[1] = Pulse.origin[2] = -1.0;
  Pulse.width[0]  = Pulse.width[1]  = Pulse.width[2]  = 6.0;
  Pulse.amplitude = 0.0001;
}

//------------------------------------------------------------------------------
void AttachPulseToGrid( vtkUniformGrid *grid )
{
  assert( "pre: grid is NULL!" && (grid != NULL) );

  vtkDoubleArray* xyz = vtkDoubleArray::New( );
  xyz->SetName( "GaussianPulse" );
  xyz->SetNumberOfComponents( 1 );
  xyz->SetNumberOfTuples( grid->GetNumberOfCells() );

  unsigned int cellIdx = 0;
  for( ; cellIdx < grid->GetNumberOfCells(); ++cellIdx )
    {
      double center[3];
      AMRCommon::ComputeCellCenter( grid, cellIdx, center );

      double r = 0.0;
      for( int i=0; i < 2; ++i )
       {
         double dx = center[i]-Pulse.origin[i];
         r += (dx*dx) / (Pulse.width[i]*Pulse.width[i]);
       }
      double f = Pulse.amplitude*std::exp( -r );

      xyz->SetTuple1( cellIdx, f );
    } // END for all cells

  grid->GetCellData()->AddArray( xyz );
  xyz->Delete();
}

//------------------------------------------------------------------------------
vtkHierarchicalBoxDataSet* GetAMRDataSet()
{
  vtkHierarchicalBoxDataSet *data = vtkHierarchicalBoxDataSet::New();
  data->Initialize();

  double origin[3];
  double h[3];
  int    ndim[3];
  int    blockId = -1;
  int    level   = -1;

  // Root Block -- Block 0,0
  ndim[0]   = 6; ndim[1]   = 5; ndim[2] = 1;
  h[0]      = h[1]      = h[2]      = 1.0;
  origin[0] = origin[1] = -2.0; origin[2] = 0.0;
  blockId   = 0;
  level     = 0;
  vtkUniformGrid *root = AMRCommon::GetGrid(origin, h, ndim);
  AttachPulseToGrid( root );
  data->SetDataSet( level, blockId,root);
  root->Delete();

  // Block 0,1
  ndim[0]   = ndim[1]   = 9; ndim[2] = 1;
  h[0]      = h[1]      = h[2]       = 0.25;
  origin[0] = origin[1] = -2.0; origin[2] = 0.0;
  blockId   = 0;
  level     = 1;
  vtkUniformGrid *grid1 = AMRCommon::GetGrid(origin, h, ndim);
  AttachPulseToGrid( grid1 );
  data->SetDataSet( level, blockId,grid1);
  grid1->Delete();

  // Block 1,1
  ndim[0]   = ndim[1]   = 9; ndim[2]   = 1;
  h[0]      = h[1]      = h[2]         = 0.25;
  origin[0] = 1.0; origin[1] = origin[2] = 0.0;
  blockId   = 1;
  level     = 1;
  vtkUniformGrid *grid3 = AMRCommon::GetGrid(origin, h, ndim);
  AttachPulseToGrid( grid3 );
  data->SetDataSet( level, blockId,grid3);
  grid3->Delete();

  vtkAMRUtilities::GenerateMetaData( data, NULL );
  data->GenerateVisibilityArrays();
  return( data );
}
