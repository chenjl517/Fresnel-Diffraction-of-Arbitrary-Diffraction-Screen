function varargout = untitled5(varargin)
% UNTITLED5 MATLAB code for untitled5.fig
%      UNTITLED5, by itself, creates a new UNTITLED5 or raises the existing
%      singleton*.
%
%      H = UNTITLED5 returns the handle to a new UNTITLED5 or the handle to
%      the existing singleton*.
%
%      UNTITLED5('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED5.M with the given input arguments.
%
%      UNTITLED5('Property','Value',...) creates a new UNTITLED5 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled5_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled5_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled5

% Last Modified by GUIDE v2.5 26-Jun-2019 23:42:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled5_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled5_OutputFcn, ...
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


% --- Executes just before untitled5 is made visible.
function untitled5_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled5 (see VARARGIN)

% Choose default command line output for untitled5
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled5 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled5_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% 选择衍射屏
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn,pn,fi]=uigetfile('*.jpg','选择图片');
imdata=imread([pn fn]);
lev=graythresh(imdata);%确定二值化阈值
global I;
I=im2bw(imdata,lev);%能否强制扩展成n*n
%set(handles.axes1,'userdata',I);
axes(handles.axes1);
imshow(I)
title('二值化后衍射屏，黑色代表不透光');


function calculate(handles)
global I;
global x;
global y;
global G;
global N;
disp(N);
L=get(handles.slider3,'Value');%控制线度
set(handles.edit3,'String',num2str(L)); 
lamda_o=get(handles.slider2,'Value');% 输入衍射波长;
set(handles.edit2,'String',num2str(lamda_o)); 
lamda=lamda_o/1e6;%单位转化为mm
k=2*pi/lamda;
z=get(handles.slider1,'Value');%衍射距离
set(handles.edit1,'String',num2str(z)); 
disp(L(1));
dx=L/N;
dxx=lamda*z/N;
z1=50*sqrt(2*(L/2)^2);%傍轴,菲涅尔衍射建议距离
z2=50*(2*(L/2)^2)/lamda;%远场，夫琅禾费衍射建议距离
disp('菲涅尔衍射区域');
disp((z>z1));
disp('夫琅禾夫衍射区域')
disp((z>z2));
disp(z2);
disp((dx^2<dxx));

if (dx^2<dxx)%采样率条件
%T-FFT算法
%IR算法
[x,y]=meshgrid(linspace(-L/2,L/2,N));%空间域
h=exp((1j*k*(x.^2+y.^2))/(2*z)); %脉冲响应函数
H=fft2(fftshift(h))*dx.^2;
B=fft2(fftshift(I));
G=(exp(1j*k*z)/(1j*lamda*z))*ifftshift(ifft2(H.*B));
else
fx=-1/(2*dx):1/L:1/(2*dx)-1/L;%频率域坐标
[FX,FY]=meshgrid(fx,fx);
%D-FFT，TF
h=exp(-1j*pi*lamda*z*(FX.^2+FY.^2))*exp(1j*k*z);
H=fftshift(h);
B=fft2(fftshift(I));
G=ifftshift(ifft2(H.*B));
end
axes(handles.axes2);
imshow(log(1+abs(G)),[]);
%imshow(abs(G));
title('衍射图样');
clear;



% 显示光强分布
function pushbutton2_Callback(hObject, eventdata, handles)
global G;
global x;
global y;
figure('NumberTitle', 'off', 'Name', '衍射强度分布');
meshz(x,y,abs(G));
title('衍射强度分布');

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
calculate(handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
calculate(handles);





% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Message='本仿真软件由兰州大学物理科学与技术学院2018级物理一班陈家麟制作,仿真结果仅供参考。';
h = msgbox(Message,'关于本软件');

% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global G;
T=num2str(clock); %clock记录当前日期时间，转换成字符串形式
T(find(isspace(T))) =[]; %去除T中的空格 
Tl=length(T); %计算T的长度
Time=T(1:(Tl-6)); %去除T中多余的数字，得到日期和时间的紧凑形式
filename=strcat(Time,'衍射图样.jpg'); %生成保存文件的路径和文件名
imwrite(log(1+abs(G)),filename);

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
calculate(handles);

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%edit反向控制slider，调用calculate
function edit3_Callback(hObject, eventdata, handles)
set(handles.slider3,'value',str2num(get(hObject,'string')));
calculate(handles);
function edit2_Callback(hObject, eventdata, handles)
set(handles.slider2,'value',str2num(get(hObject,'string')));
calculate(handles);
function edit1_Callback(hObject, eventdata, handles)
set(handles.slider1,'value',str2num(get(hObject,'string')));
calculate(handles);



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global N;
N=str2double(get(handles.edit4,'String'));%设置采样率
str=strcat('图像要求',num2str(N),'*',num2str(N),'像素');
set(handles.text13,'String',str);
disp(N);
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
