 function varargout = Label(varargin)
% LABEL MATLAB code for Label.fig
%      LABEL, by itself, creates a new LABEL or raises the existing
%      singleton*.
% 
%      H = LABEL returns the handle to a new LABEL or the handle to
%      the existing singleton*.
%
%      LABEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABEL.M with the given input arguments.
%
%      LABEL('Property','Value',...) creates a new LABEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Label_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Label_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Label

% Last Modified by GUIDE v2.5 16-Apr-2017 22:04:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Label_OpeningFcn, ...
                   'gui_OutputFcn',  @Label_OutputFcn, ...
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


% --- Executes just before Label is made visible.
function Label_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Label (see VARARGIN)

% Choose default command line output for Label
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Label wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Label_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browser.
function browser_Callback(hObject, eventdata, handles)
% hObject    handle to browser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile({'*.jpg';'*.dcm';'*.tif';'*.';'*.*'},'File Selector');
oldpath = cd(pathname);
errors = 0;
%set(handles.errorme,'string',[]);
isdcm = isdicom (filename);
filetype = filename(strfind(filename,'.'):end);
%---------------add extension if needed-----------------------
if isempty(filetype) 
    if isdcm
        lst = dir('*.*');
        for i = 3:length(lst)
            oldname = lst(i).name;
            movefile(oldname,[oldname,'.dcm'])
        end
        filetype = '.dcm';
        filename = [filename,'.dcm'];
    else
        lst = dir('*.*');
        lengdd = length(dir('*.'));
        for i = 1+lengdd:length(lst)
            oldname = lst(i).name;
            movefile(oldname,[oldname,'.tif'])
        end
        filetype = '.tif';
       filename = [filename,'.tif'];
    end
end
%--------------findcommenname---------------------------------        
naminvl = [];
for i = 1:length(filename)
    invl = str2double(filename(i));
    if ~isnan(invl)
        naminvl = [naminvl,i];
    end
end
if length(naminvl) == 1
    commenname = filename(1:naminvl(1)-1);
else
    nampo = naminvl(diff(naminvl)==1);
    commenname = filename(1:nampo(1)-1);
end
%--------------------------------------------
set(handles.pathway,'String',pathname)
listfile = dir(['*',filetype,'*']);
name = {listfile.name};
str  = sprintf('%s#', name{:});
num  = sscanf(str, [commenname,'%d',filetype,'#']);
[~, index] = sort(num);
filenamesort = name(index);
if isdcm
    I1=dicomread(filenamesort{1});
else 
    I1 = imread(filenamesort{1});
end
[row,col] = size(I1);
totalnum = length(filenamesort);
centernum = round(totalnum/2);
allimage = ones(row,col,totalnum);
try 
    if isdcm
        for i = 1:totalnum
        allimage(:,:,i) =dicomread(filenamesort{i});
        end
    else
        for i = 1:totalnum
        allimage(:,:,i) = imread(filenamesort{i});
        end
    end
catch 
 %   set(handles.errorme,'String','Cannot load all images');
    errors = 1;
end
if ~errors
%    set(handles.errorme,'string','Images loaded');
    disc = zeros(row,col,totalnum);
    allimage = uint8(allimage/max(max(max(allimage)))*255);
    hObject.UserData.image = allimage;
    hObject.UserData.image0 = allimage;
    hObject.UserData.disc = disc;
    currentnum = sscanf (filename,[commenname,' %d ',filetype]);
    set(handles.totalnum,'String',totalnum);
    toprocess = 1:totalnum;
    handles.toprocess.UserData = toprocess;
    processed = [];
    handles.processed.UserData = processed;
    set(handles.toprocess,'String',mat2str(toprocess));
    set(handles.row,'String',row);
    set(handles.col,'String',col);
    sugthres = graythresh(allimage(centernum));
    if sugthres < 0.001
        sugthres = 0.05;
    end
    sugthres = 0.3;
    set(handles.threshold,'String',sugthres);
    axes(handles.axes1)
    for i = 1:totalnum
        if ~isempty(strfind(filenamesort{i},num2str(currentnum)))
            currentnum = i;
            break;
        end
    end
    set(handles.cslice,'String',currentnum); 
    imshow(allimage(:,:,currentnum))
end
cd(oldpath)
guidata(hObject,handles)



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dilated_Callback(hObject, eventdata, handles)
% hObject    handle to dilated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dilated as text
%        str2double(get(hObject,'String')) returns contents of dilated as a double


% --- Executes during object creation, after setting all properties.
function dilated_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dilated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function drop_Callback(hObject, eventdata, handles)
% hObject    handle to drop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drop as text
%        str2double(get(hObject,'String')) returns contents of drop as a double


% --- Executes during object creation, after setting all properties.
function drop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function brush_size_Callback(hObject, eventdata, handles)
% hObject    handle to brush_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of brush_size as text
%        str2double(get(hObject,'String')) returns contents of brush_size as a double


% --- Executes during object creation, after setting all properties.
function brush_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brush_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in makeup.
function makeup_Callback(hObject, eventdata, handles)
% hObject    handle to makeup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allimage = handles.browser.UserData.image;
cslice = str2double(get(handles.cslice,'string'));
pointsize = str2double(get(handles.brush_size,'string'));
row = str2double(get(handles.row,'string'));
col = str2double(get(handles.col,'string'));
cimage = allimage(:,:,cslice);
axes(handles.axes1);
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
gcf;
set(gcf, 'KeyPressFcn', @myKeyPressFcn);
while ~KEY_IS_PRESSED
freehand = imfreehand('Closed',false);
points=freehand.getPosition();
delete(freehand);
if ~isempty(points)
    [rowfh,~] = size(points);
    Points = [];
    for ii = 1:rowfh-1
        point1 = points(ii,:);
        point2 = points(ii+1,:);
        xx=linspace(point1(1),point2(1),40)';
        yy=interp1q([point1(1),point2(1)]',[point1(2),point2(2)]',xx(1:end-1));
        Points = [Points;[xx(1:end-1),yy]];
    end
    [rowfh,~] = size(Points);
    for ii = 1:rowfh
    point = Points(ii,:);
    rown = round(point(2));
    coln = round(point(1));
    %%
    try
    cimage(rown-pointsize:rown+pointsize,coln-pointsize:coln+pointsize)=255; % can be improved;
    end
    cimage=cimage(1:row,1:col);
    end
    imshow(cimage,[])
end
ppoint = ginput(1);
set(gcf,'Pointer','arrow')
if isempty(ppoint)
    break;
end
end
allimage(:,:,cslice) = cimage;
handles.browser.UserData.image = allimage;
guidata(hObject,handles)
function myKeyPressFcn(hObject, event)
global KEY_IS_PRESSED
KEY_IS_PRESSED  = 1;


% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allimage = handles.browser.UserData.image;
cslice = str2double(get(handles.cslice,'string'));
pointsize = str2double(get(handles.brush_size,'string'));
row = str2double(get(handles.row,'string'));
col = str2double(get(handles.col,'string'));
cimage = allimage(:,:,cslice);
axes(handles.axes1);
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
gcf;
set(gcf, 'KeyPressFcn', @myKeyPressFcn);
while ~KEY_IS_PRESSED
freehand = imfreehand('Closed',false);
points=freehand.getPosition();
delete(freehand);
if ~isempty(points)
    [rowfh,~] = size(points);
    Points = [];
    for ii = 1:rowfh-1
        point1 = points(ii,:);
        point2 = points(ii+1,:);
        xx=linspace(point1(1),point2(1),40)';
        yy=interp1q([point1(1),point2(1)]',[point1(2),point2(2)]',xx(1:end-1));
        Points = [Points;[xx(1:end-1),yy]];
    end
    [rowfh,~] = size(Points);
    for ii = 1:rowfh
    point = Points(ii,:);
    rown = round(point(2));
    coln = round(point(1));
    %%
    try
    cimage(rown-pointsize:rown+pointsize,coln-pointsize:coln+pointsize)=0; % can be improved;
    end
    cimage=cimage(1:row,1:col);
    end
    imshow(cimage,[])
end
ppoint = ginput(1);
set(gcf,'Pointer','arrow')
if isempty(ppoint)
    break;
end
end
allimage(:,:,cslice) = cimage;
handles.browser.UserData.image = allimage;
guidata(hObject,handles)


% --- Executes on button press in disc.
function disc_Callback(hObject, eventdata, handles)
% hObject    handle to disc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allimage = handles.browser.UserData.image;
csnum = str2double(get(handles.cslice,'string'));
bthreshold = str2double(get(handles.threshold,'string'));
dropnum = str2double(get(handles.drop,'string'));
disk = str2double(get(handles.dilated,'string'));
cimage = allimage(:,:,csnum);
bimage = imbinarize(cimage,bthreshold);
BW = bwareaopen(bimage,dropnum,4);
BW = imdilate(BW, strel('disk',disk));
% BW = ~BW;
% BW = bwareaopen(BW,round(dropnum/10),4);
% BW = ~BW;
axes(handles.axes2);
imshow(BW)
hObject.UserData = BW;
guidata(hObject,handles)


% --- Executes on button press in redo.
function redo_Callback(hObject, eventdata, handles)
% hObject    handle to redo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cslide = str2double(get(handles.cslice,'string'));
allimage = handles.browser.UserData.image;
allimages0 = handles.browser.UserData.image0;
image0 = allimages0(:,:,cslide);
allimage(:,:,cslide) = image0;
axes(handles.axes1);
imshow(image0,[]);
handles.browser.UserData.image = allimage;
guidata(hObject,handles);


% --- Executes on button press in record.
function record_Callback(hObject, eventdata, handles)
% hObject    handle to record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cnum = str2double(get(handles.cslice,'string'));
toprocess = handles.toprocess.UserData;
processed = handles.processed.UserData;
disc = handles.browser.UserData.disc;
BW = handles.disc.UserData;
disc(:,:,cnum) = BW;
handles.browser.UserData.disc = disc;
toprocess = toprocess(toprocess ~= cnum);
processed = [processed,cnum];
processed = sort(processed);
handles.toprocess.UserData = toprocess;
handles.processed.UserData = processed;
set(handles.toprocess,'String',mat2str(toprocess));
set(handles.processed,'String',mat2str(processed));
guidata(hObject,handles);

% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cnum = str2double(get(handles.cslice,'string'));
allimage= handles.browser.UserData.image;
cnum = cnum +1;
image= allimage(:,:,cnum);
set(handles.cslice,'string',cnum);
axes(handles.axes1)
imshow(image,[])
guidata(hObject,handles)


% --- Executes on button press in previous.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cnum = str2double(get(handles.cslice,'string'));
allimage= handles.browser.UserData.image;
cnum = cnum-1;
image= allimage(:,:,cnum);
set(handles.cslice,'string',cnum);
axes(handles.axes1)
imshow(image,[])
guidata(hObject,handles)



function cslice_Callback(hObject, eventdata, handles)
% hObject    handle to cslice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cslice as text
%        str2double(get(hObject,'String')) returns contents of cslice as a double


% --- Executes during object creation, after setting all properties.
function cslice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cslice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotcurrent.
function plotcurrent_Callback(hObject, eventdata, handles)
% hObject    handle to plotcurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cslice = str2double(get(handles.cslice,'string'));
allimage = handles.browser.UserData.image;
cimage = allimage(:,:,cslice);
axes(handles.axes1);
imshow(cimage,[]);
guidata(hObject,handles)


% --- Executes on button press in fillholes.
function fillholes_Callback(hObject, eventdata, handles)
% hObject    handle to fillholes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allimage = handles.browser.UserData.image;
csnum = str2double(get(handles.cslice,'string'));
bthreshold = str2double(get(handles.threshold,'string'));
dropnum = str2double(get(handles.drop,'string'));
disk = str2double(get(handles.dilated,'string'));
cimage = allimage(:,:,csnum);
bimage = imbinarize(cimage,bthreshold);
BW = bwareaopen(bimage,dropnum,4);
BW = imdilate(BW, strel('disk',disk));
BW = ~BW;
BW = bwareaopen(BW,dropnum*2,4);
BW = ~BW;
axes(handles.axes2);
imshow(BW)
handles.disc.UserData = BW;
guidata(hObject,handles)


% --- Executes on button press in allgarbage.
function allgarbage_Callback(hObject, eventdata, handles)
% hObject    handle to allgarbage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cnum = str2double(get(handles.cslice,'string'));
toprocess = handles.toprocess.UserData;
processed = handles.processed.UserData;
disc = handles.browser.UserData.disc;
[row,col,~] = size(disc);
BW = zeros(row,col);
disc(:,:,cnum) = BW;
handles.browser.UserData.disc = disc;
toprocess = toprocess(toprocess ~= cnum);
processed = [processed,cnum];
processed = sort(processed);
handles.toprocess.UserData = toprocess;
handles.processed.UserData = processed;
set(handles.toprocess,'String',mat2str(toprocess));
set(handles.processed,'String',mat2str(processed));
guidata(hObject,handles);




function toprocess_Callback(hObject, eventdata, handles)
% hObject    handle to toprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of toprocess as text
%        str2double(get(hObject,'String')) returns contents of toprocess as a double



% --- Executes during object creation, after setting all properties.
function toprocess_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function processed_Callback(hObject, eventdata, handles)
% hObject    handle to processed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of processed as text
%        str2double(get(hObject,'String')) returns contents of processed as a double


% --- Executes during object creation, after setting all properties.
function processed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savedata.
function savedata_Callback(hObject, eventdata, handles)
% hObject    handle to savedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allimages = handles.browser.UserData.image0;
disc = handles.browser.UserData.disc;
name = get(handles.name,'string');
allimages = double(allimages);
save([name,'image.mat'],'allimages');
save([name,'label.mat'],'disc');



function name_Callback(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name as text
%        str2double(get(hObject,'String')) returns contents of name as a double


% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
