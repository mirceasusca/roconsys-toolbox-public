Based on the article "Unified CACSD Toolbox for Hybrid Simulation and Robust Controller Synthesis with Applications in DC-to-DC Power Converter Control" [to be published]

# Toolbox documentation

## Objectives:
* exclusively MATLAB-based, does not use Simulink
* Object-Oriented structure
* easy Model-in-the-Loop simulations: linearized, nonlinear system, hybrid counterpart using the same interface
* automatically compute least conservative low-order uncertainty bounds
* use the well-established mu synthesis framework to design robust controllers using the mixed-sensitivity loop-shaping plant augmentation

## Software requirements:
* MATLAB, with the following extensions:
	* Control System Toolbox
	* Robust Control Toolbox
	* Optimization Toolbox 
	* HyEQToolbox installation: https://www.mathworks.com/videos/hyeq-a-toolbox-for-simulation-of-hybrid-dynamical-systems-81992.html

## Toolbox structure:

* benchmark_plants
* case_studies
* data # exposes data and objects used for the case studies in the paper
    * clp-dc-dc-boost-07-Feb-2021 00:41:10.mat
    * clp-dc-dc-buck-07-Feb-2021 01:01:29.mat
    * clp-dc-dc-sepic-06-Feb-2021 22:25:39.mat

* oop_sys_toolbox
    * closed_loop_problem
	* ClosedLoopControlProblem
    * lti_analysis
	* PlantAnalysis
    * robust_synthesis
	* RobustControlOptimProblem
	* UncertainHybridPlantFactory
        * UncertainPlantFactory
	* UncertaintyOptimProblem
    * system_classes
        * **contiunuous_systems_interface**
            * **connections**
                * SeriesConnectionSystem
                * ParallelConnectionSystem
                * FeedbackConnectionSystem
                * LLFTConnectionSystem
                * ULFTConnectionSystem [not included here]
            * **System**
            * **LTISystem**
            * **LTIEqSystem**
        * **hybrid_systems_interface**
            * **connections**
                * HybridSeriesConnectionSystem
                * HybridParallelConnectionSystem
                * HybridLLFTConnectionSystem
                * HybridULFTConnectionSystem [not included here]
            * **HybridSystem**
            * **HybridSystemWrapper**
    * utils
* tests

## Observations
1) Will need to change paths from setup.m (toolbox_path) and modify path logic from ClosedLoopControlProblem (save/load methods)
2) To be updated in further iterations
