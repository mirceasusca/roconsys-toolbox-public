##  Deprecated

# Toolbox documentation

## Objectives:
* exclusively MATLAB-based, does not use Simulink
* Object-Oriented structure
* easy Model-in-the-Loop simulations: linearized, nonlinear system, hybrid counterpart using the same interface

## Software requirements:
* HyEQToolbox installation
* Control System Toolbox
* Robust Control Toolbox
* Optimization Toolbox 

## Toolbox structure:

* benchmark_plants
* **bibliography**
* dc_dc_conv
    * **BoostConverterSystem**
    * **BoostHybrid3ConverterSystem**
    * UncertainBoostConverterFactory
* **oop_sys_toolbox**
    * lti_analysis
    * quantization
    * robust_synthesis
    * system_classes
        * **contiunuous_systems_interface**
            * **connections**
                * SeriesConnectionSystem
                * ParallelConnectionSystem
                * FeedbackConnectionSystem
                * LLFTConnectionSystem
                * ULFTConnectionSystem
            * **System**
            * **LTISystem**
            * **LTIEqSystem**
        * **hybrid_systems_interface**
            * **connections**
                * HybridSeriesConnectionSystem
                * HybridParallelConnectionSystem
                * HybridLLFTConnectionSystem
                * HybridULFTConnectionSystem
            * **HybridSystem**
            * **HybridSystemWrapper**
        * UncertainPlantFactory
    * utils
* tests

## Relevant functionalities:
* System (Abstract): (F,h)
    * function dx = F(obj,x,u,t)
    * function y = h(obj,x,u,t)
    * function [x,t,y] = sim(obj,x0,u,tfin)
    * function [x,t,y] = simInitCond(obj,x0,u0,tfin)
    * function [A,B,C,D,y0,x0,u0,t0] = linearize(obj,x0,u0,t0)
    * function isLTI = isLTISystem(obj)
    * function [x0,u0,y0,t0] = findEqPoint(obj,eqOpts)
        * set_eq_point_options.m

* LTISystem < System: (F,h) based on (A,B,C,D)
* LTIEqSystem < System: (F,h) based on (A,B,C,D) and (x0,u0,t0) -- bib
* GainSystem < System: ([],h) based on ([],[],[],D)

* HybridSystem (Abstract) < System: (F,G,C,D,h) using HyEQToolbox -- bib
* HybridSystemWrapper < HybridSystem: turns (F,h) object into (F,G,C,D,h)

* UncertainPlantFactory (Abstract):
Generate plant examples based on a specified uncertainty set.
    * function Sys = getNominalPlant(obj)
    * function Sys = getRandomPlant(obj)

### System connections:
* SeriesConnectionSystem < System
* ParallelConnectionSystem < System
* LLFTConnectionSystem < System
* ULFTConnectionSystem < System
* HybridSeriesConnectionSystem < HybridSystem & SeriesConnectionSystem
* HybridParallelConnectionSystem < HybridSystem & ParallelConnectionSystem
* HybridLLFTConnectionSystem < HybridSystem & LLFTConnectionSystem
* HybridULFTConnectionSystem < HybridSystem & ULFTConnectionSystem

### Benchmark plants:
* BoostConverterSystem: nonlinear averaged-model
* BoostHybrid3ConverterSystem: hybrid Boost DC-DC Converter with 3 hybrid states

## Relevant test files:
* tests/tests_hybrid_systems/test_boost_hybrid_3_model_and_control.m
* tests/test_connections/...
* tests/test_fsolve_eq_converters.m
* tests_dc_dc_conv/...# roconsys-toolbox
