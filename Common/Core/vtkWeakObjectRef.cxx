/*=========================================================================

  Program:   Visualization Toolkit
  Module:    vtkArray.cxx

-------------------------------------------------------------------------
  Copyright 2008 Sandia Corporation.
  Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
  the U.S. Government retains certain rights in this software.
-------------------------------------------------------------------------

  Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen
  All rights reserved.
  See Copyright.txt or http://www.kitware.com/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notice for more information.

=========================================================================*/

#include "vtkWeakObjectRef.h"
#include "vtkWeakPointer.h"
#include "vtkObjectFactory.h"
//
// Standard functions
//
vtkStandardNewMacro(vtkWeakObjectRef)


//----------------------------------------------------------------------------

vtkWeakObjectRef::vtkWeakObjectRef()
{
}

//----------------------------------------------------------------------------

vtkWeakObjectRef::~vtkWeakObjectRef()
{
}

//----------------------------------------------------------------------------

void vtkWeakObjectRef::PrintSelf(ostream &os, vtkIndent indent)
{
  Superclass::PrintSelf(os, indent);

}

void vtkWeakObjectRef::Set(vtkObject *obj)
{
  this->Obj = obj;

}

vtkObject* vtkWeakObjectRef::Get() {
  return this->Obj;
}


