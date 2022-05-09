function varargout = VisualRS(varargin)
% VISUALRS MATLAB code for VisualRS.fig
%      VISUALRS, by itself, creates a new VISUALRS or raises the existing
%      singleton*.
%
%      H = VISUALRS returns the handle to a new VISUALRS or the handle to
%      the existing singleton*.
%
%      VISUALRS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALRS.M with the given input arguments.
%
%      VISUALRS('Property','Value',...) creates a new VISUALRS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VisualRS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VisualRS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VisualRS

% Last Modified by GUIDE v2.5 27-May-2013 13:22:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VisualRS_OpeningFcn, ...
                   'gui_OutputFcn',  @VisualRS_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before VisualRS is made visible.
function VisualRS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VisualRS (see VARARGIN)

% Choose default command line output for VisualRS
handles.output = hObject;
handles.rsmodel = varargin{1};

outputidx = handles.rsmodel.outputidx; 
inputidx = handles.rsmodel.inputidx;
para1 = inputidx(1);
para2 = inputidx(1);

if outputidx == 0
    set(handles.output_popupmenu,'String',handles.rsmodel.outputNames);
    set(handles.output_popupmenu,'Value',1);
elseif outputidx > 0
    set(handles.output_popupmenu,'String',handles.rsmodel.outputNames(outputidx));
    set(handles.output_popupmenu,'Value',outputidx);
elseif outputidx == -1
    set(handles.output_popupmenu,'String','weighting function');
    set(handles.output_popupmenu,'Value',1);
elseif outputidx == -2
    set(handles.output_popupmenu,'String','distance to origin');
    set(handles.output_popupmenu,'Value',1);
end

inputNames = handles.rsmodel.inputNames(handles.rsmodel.inputidx);
set(handles.para1_popupmenu,'String',inputNames);
set(handles.para2_popupmenu,'String',inputNames);
set(handles.para1_popupmenu,'Value',1);
set(handles.para2_popupmenu,'Value',1);

if outputidx == 0; VRS.output = 1;
else VRS.output = outputidx; end;
VRS.para1 = para1;
VRS.para2 = para2;
VRS.plot_type = 'surf';

handles.VRS = VRS;

plotRS(handles.rsmodel,handles.VRS,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VisualRS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VisualRS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in surf_button.
function surf_button_Callback(hObject, eventdata, handles)
% hObject    handle to surf_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.VRS.plot_type = 'surf';
plotRS(handles.rsmodel,handles.VRS,handles);
guidata(hObject, handles);

% --- Executes on button press in mesh_button.
function mesh_button_Callback(hObject, eventdata, handles)
% hObject    handle to mesh_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.VRS.plot_type = 'mesh';
plotRS(handles.rsmodel,handles.VRS,handles);
guidata(hObject, handles);

% --- Executes on button press in contour_button.
function contour_button_Callback(hObject, eventdata, handles)
% hObject    handle to contour_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.VRS.plot_type = 'contour';
plotRS(handles.rsmodel,handles.VRS,handles);
guidata(hObject, handles);

% --- Executes on button press in save_fig_button.
function save_fig_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_fig_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
formatcell = {'*.fig','MATLAB Figure';...
    '*.eps','EPS file'; ...
    '*.jpg','JPEG image'; ...
    '*.png','Portable Network Graphics file'; ...
    '*.tif','TIFF image'};
[FileName, PathName, FilterIndex] = uiputfile(formatcell,'Save figure as');
if ischar(FileName) && ischar(PathName)
    extend = formatcell{FilterIndex,1}(3:end);
    plotRS(handles.rsmodel,handles.VRS,handles,[PathName,FileName],extend);
end


% --- Executes on selection change in output_popupmenu.
function output_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to output_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns output_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from output_popupmenu
val = get(hObject, 'Value');

inputidx = handles.rsmodel.inputidx;
set(handles.para1_popupmenu,'String',{handles.rsmodel.inputNames(inputidx)});
set(handles.para2_popupmenu,'String',{handles.rsmodel.inputNames(inputidx)});
set(handles.para1_popupmenu,'Value',1);
set(handles.para2_popupmenu,'Value',1);
para1 = inputidx(1);
para2 = inputidx(1);

VRS.output = val;
VRS.para1 = para1;
VRS.para2 = para2;
VRS.plot_type = 'surf';
handles.VRS = VRS;

plotRS(handles.rsmodel,handles.VRS,handles);
guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function output_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in para1_popupmenu.
function para1_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to para1_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns para1_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from para1_popupmenu
val = get(hObject, 'Value');
inputidx = handles.rsmodel.inputidx;
handles.VRS.para1 = inputidx(val);
plotRS(handles.rsmodel,handles.VRS,handles);
guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function para1_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to para1_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in para2_popupmenu.
function para2_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to para2_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns para2_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from para2_popupmenu
val = get(hObject, 'Value');
inputidx = handles.rsmodel.inputidx;
handles.VRS.para2 = inputidx(val);
plotRS(handles.rsmodel,handles.VRS,handles);
guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function para2_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to para2_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Plot response surface
function plotRS(rsmodel,VRS,handles,filepath,extend)
inputidx = rsmodel.inputidx;
outputidx = rsmodel.outputidx;
P1LB = rsmodel.xlbS(VRS.para1);
P1UB = rsmodel.xubS(VRS.para1);
P2LB = rsmodel.xlbS(VRS.para2);
P2UB = rsmodel.xubS(VRS.para2);
para1label = rsmodel.inputNames(inputidx(VRS.para1));
para2label = rsmodel.inputNames(inputidx(VRS.para2));
if VRS.output > 0
    outputlabel = rsmodel.outputNames(VRS.output);
elseif VRS.output == -1
    outputlabel = 'weighting function';
elseif VRS.output == -2
    outputlabel = 'distance to origin';
end
bins = 100;
p1step = (P1UB - P1LB)/bins;
p2step = (P2UB - P2LB)/bins;

if nargin == 3
    filepath = ''; extend = '';
end

if VRS.para1 == VRS.para2 
    % plot 1D response surface
    X = zeros(bins+1,rsmodel.nInputS);

    for j = 1:rsmodel.nInputS
        if j == VRS.para1
            X(:,j) = P1LB:p1step:P1UB;
        else
            X(:,j) = rsmodel.xdf(inputidx(j))*ones(bins+1,1);
        end
    end
    
    if outputidx == 0
        Y = rsmodel.run(X);
        Y = Y(:,VRS.output);
    else
        Y = rsmodel.run(X);
    end

    xgv = X(:,VRS.para1);
    ygv = Y;
    xt = rsmodel.fromunit(rsmodel.xt);
    xtgv = xt(:,VRS.para1);
    if outputidx == 0
        ytgv = rsmodel.yt(:,VRS.output);
    else
        ytgv = rsmodel.yt;
    end

    axes(handles.fig_axes1); newplot;
    plot(xgv,ygv,'b-',xtgv,ytgv,'ro');
%     legend('response surface','sample point');
    xlabel(para1label);
    ylabel(outputlabel);
    
    ytt = rsmodel.rununit(rsmodel.xt);
    if outputidx == 0; ytt = ytt(VRS.output); end
    mse = CalcMSE(ytt,rsmodel.yt(:,VRS.output));
    rmse = CalcRMSE(ytt,rsmodel.yt(:,VRS.output));
    nrmse = CalcNRMSE(ytt,rsmodel.yt(:,VRS.output));
    cvrmse = CalcCVRMSE(ytt,rsmodel.yt(:,VRS.output));
    errstr = {['MSE = ',num2str(mse)],['RMSE = ',num2str(rmse)],...
        ['NRMSE = ',num2str(nrmse)],['CVRMSE = ',num2str(cvrmse)]};
    set(handles.RSerr,'String',errstr);
    
    if nargin ~= 3
        saveas(gcf,filepath,extend);
        close(fig);
    end
    
else
    % plot 2D response surface
    xgv = P1LB:p1step:P1UB;
    ygv = P2LB:p2step:P2UB;
    [xmesh, ymesh] = meshgrid(xgv,ygv);
    
    X = zeros((bins+1)^2,rsmodel.nInputS);
    X(:,VRS.para1) = reshape(xmesh,(bins+1)^2,1);
    X(:,VRS.para2) = reshape(ymesh,(bins+1)^2,1);
    for j = 1:rsmodel.nInputS
        if j ~= VRS.para1 && j ~= VRS.para2
            X(:,j) = rsmodel.xdf(inputidx(j))*ones((bins+1)^2,1);
        end
    end
    
    if outputidx == 0
        Y = rsmodel.run(X);
        Y = Y(:,VRS.output);
    else
        Y = rsmodel.run(X);
    end
    zmesh = reshape(Y,bins+1,bins+1);
    
    xt = rsmodel.fromunit(rsmodel.xt);
    xtgv = xt(:,VRS.para1);
    ytgv = xt(:,VRS.para2);
    if outputidx == 0
        ztgv = rsmodel.yt(:,VRS.output);
    else
        ztgv = rsmodel.yt;
    end
    
    if nargin == 3
        axes(handles.fig_axes1); newplot;
    else
        fig = figure;
    end
    
    switch VRS.plot_type
        case 'surf'
            surf(xmesh,ymesh,zmesh); hold on;
            plot3(xtgv,ytgv,ztgv,'ro'); hold off;
%             legend('response surface','sample point');
            xlabel(para1label);
            ylabel(para2label);
            zlabel(outputlabel);
        case 'mesh'
            mesh(xmesh,ymesh,zmesh); hold on;
            plot3(xtgv,ytgv,ztgv,'ro'); hold off;
%             legend('response surface','sample point');
            xlabel(para1label);
            ylabel(para2label);
            zlabel(outputlabel);
        case 'contour'
            [C, h] = contour(xmesh,ymesh,zmesh); hold on;
            set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
%             plot(xtgv,ytgv,'ro'); 
            hold off;
%             legend('response surface','sample point');
            xlabel(para1label);
            ylabel(para2label);
    end
    
    ytt = rsmodel.rununit(rsmodel.xt);
    if outputidx == 0; ytt = ytt(VRS.output); end
    mse = CalcMSE(ytt,rsmodel.yt(:,VRS.output));
    rmse = CalcRMSE(ytt,rsmodel.yt(:,VRS.output));
    nrmse = CalcNRMSE(ytt,rsmodel.yt(:,VRS.output));
    cvrmse = CalcCVRMSE(ytt,rsmodel.yt(:,VRS.output));
    errstr = {['MSE = ',num2str(mse)],['RMSE = ',num2str(rmse)],...
        ['NRMSE = ',num2str(nrmse)],['CVRMSE = ',num2str(cvrmse)]};
    set(handles.RSerr,'String',errstr);
    
    if nargin ~= 3
        saveas(gcf,filepath,extend);
        close(fig);
    end
    
end
