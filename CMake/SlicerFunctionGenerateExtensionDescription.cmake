################################################################################
#
#  Program: 3D Slicer
#
#  Copyright (c) 2010 Kitware Inc.
#
#  See Doc/copyright/copyright.txt
#  or http://www.slicer.org/copyright/copyright.txt for details.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  This file was originally developed by Jean-Christophe Fillion-Robin, Kitware Inc.
#  and was partially funded by NIH grant 3P41RR013218-12S1
#
################################################################################

INCLUDE(SlicerMacroExtractRepositoryInfo)

FUNCTION(slicerFunctionGenerateExtensionDescription)
  set(options)
  set(oneValueArgs EXTENSION_NAME EXTENSION_CATEGORY EXTENSION_STATUS EXTENSION_HOMEPAGE EXTENSION_DESCRIPTION DESTINATION_DIR SLICER_WC_REVISION SLICER_WC_ROOT)
  set(multiValueArgs)
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Sanity checks
  SET(expected_nonempty_vars EXTENSION_NAME EXTENSION_CATEGORY EXTENSION_STATUS EXTENSION_HOMEPAGE EXTENSION_DESCRIPTION SLICER_WC_REVISION SLICER_WC_ROOT)
  FOREACH(var ${expected_nonempty_vars})
    IF("${MY_${var}}" STREQUAL "")
      MESSAGE(FATAL_ERROR "error: ${var} CMake variable is empty !")
    ENDIF()
  ENDFOREACH()
  
  SET(expected_existing_vars DESTINATION_DIR)
  FOREACH(var ${expected_existing_vars})
    IF(NOT EXISTS "${MY_${var}}")
      MESSAGE(FATAL_ERROR "error: ${var} CMake variable points to a inexistent file or directory: ${MY_${var}}")
    ENDIF()
  ENDFOREACH()
  
  SET(filename ${MY_DESTINATION_DIR}/${MY_EXTENSION_NAME}.s4ext)
  
  SlicerMacroExtractRepositoryInfo(VAR_PREFIX Extension)
  
  SET(scm_type ${Extension_WC_TYPE})
  #SET(scm_path_token ${Extension_WC_TYPE}path)
  SET(scm_path_token scmurl)
  SET(scm_url ${Extension_WC_URL})
  
  #message(MY_SLICER_WC_ROOT:${MY_SLICER_WC_ROOT})
  #message(MY_SLICER_WC_REVISION:${MY_SLICER_WC_REVISION})
  #message(Extension_WC_ROOT:${Extension_WC_ROOT})
  #message(Extension_WC_REVISION:${Extension_WC_REVISION})
  
  # If both Root and Revision matches, let's assume both Slicer source and Extension source 
  # are checkout on the same filesystem.
  # This is useful for testing purposes
  IF(${Extension_WC_ROOT} STREQUAL ${MY_SLICER_WC_ROOT}
     AND ${Extension_WC_REVISION} STREQUAL ${MY_SLICER_WC_REVISION})
    SET(scm_type local)
    #SET(scm_path_token localpath)
    SET(scm_url ${CMAKE_CURRENT_SOURCE_DIR})
  ENDIF()
  
  
  FILE(WRITE ${filename} 
"#
# First token of each non-comment line is the keyword and the rest of the line 
# (including spaces) is the value.
# - the value can be blank
#

# This is source code manager (i.e. svn)
scm ${scm_type}
${scm_path_token} ${scm_url}

# list dependencies
# - These should be names of other modules that have .s4ext files 
# - The dependencies will be built first
depends

# homepage
homepage    ${MY_EXTENSION_HOMEPAGE}

# Match category in the xml description of the module (where it shows up in Modules menu)
category    ${MY_EXTENSION_CATEGORY}

# Give people an idea what to expect from this code 
#  - Is it just a test or something you stand beind?
status      ${MY_EXTENSION_STATUS}

# One line stating what the module does
description ${MY_EXTENSION_DESCRIPTION}")

MESSAGE(STATUS "Extension description has been written to: ${filename}")


ENDFUNCTION()

