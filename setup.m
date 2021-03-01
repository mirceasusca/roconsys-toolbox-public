global toolbox_path

% overwrite with current folder path
toolbox_path = '.../roconsys_toolbox_public/';

cd(toolbox_path)
addpath(genpath(toolbox_path))

clc
disp('>> Succesfully configured ROCONSYS Toolbox path')