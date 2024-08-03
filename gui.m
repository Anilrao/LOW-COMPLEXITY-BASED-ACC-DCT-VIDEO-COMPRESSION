function varargout = gui(varargin)
% GUI M-file for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above output to modify the response to help gui

% Last Modified by GUIDE v2.5 21-Dec-2009 10:12:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no Reconstruction args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line Reconstruction for gui
handles.Reconstruction = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
a=ones(256,256);
axes(handles.one);
imshow(a);

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning Reconstruction args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line Reconstruction from handles structure
varargout{1} = handles.Reconstruction;


% --- Executes on button press in Browse_Video.
function Browse_Video_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_Video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 [filename, pathname] = uigetfile('*.avi', 'Pick an Image');
    if isequal(filename,0) || isequal(pathname,0)
       warndlg('image is not selected');
    else
      a=aviread(filename);
      axes(handles.one);
      movie(a);
      helpdlg('Click Frame Separation');
    end
    handles.filename=filename;
    handles.inputimage=a;
    guidata(hObject, handles);

% --- Executes on button press in Frame_Separation.
function Frame_Separation_Callback(hObject, eventdata, handles)
% hObject    handle to Frame_Separation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename=handles.filename;
str1='frame';
str2='.bmp';
file=aviinfo(filename); % to get inforamtaion abt video file
frm_cnt=file.NumFrames          % No.of frames in the video file  

    h = waitbar(0,'Please wait...');
for i=1:frm_cnt
    frm(i)=aviread(filename,i);         % read the Video file
    frm_name=frame2im(frm(i));      % Convert Frame to image file
    filename1=strcat(num2str(i),str2);
    frm_name = rgb2gray(frm_name);
    imwrite(frm_name,filename1);      % Write image file  
     waitbar(i/frm_cnt,h)
end
 close(h)
 
helpdlg('Frame seperation is Completed');   


% --- Executes on button press in Encoding.
function Encoding_Callback(hObject, eventdata, handles)
% hObject    handle to Encoding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

q=1; %%%%%%%%%%%%%%%% quantization value

str1='frame';
str2='.bmp';

Bitstream=[];
Bitst=[];
j1=1;
tic;

for f=1:4:4
%     waitbar(f/8,h)
filename_1=strcat(num2str(f),str2);%%%%%%%%%%%%%% form filename
Image1=imread(filename_1);
% Image1=rgb2gray(Image1);
[row col]=size(Image1);
handles.row=row;
 handles.col=col;
 guidata(hObject, handles);
% Image1=imresize(Image1,[256,256]); % resize for wavelet
% [r_1 c_1]=size(Image1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DCT
out = acc(f);        %%%%%%%%%%%%% ACCORDION FUNCTION 
Image1=round(out);
 %Enc = myDCT(Image1); 
 [Enc,s] = wavedec2(Image1,2,'db1');
 [r c]= size(Enc);
 Input_filesize=r*c*4;
			for i=1:r
                for j=1:c
                    QEnc(i,j)=Enc(i,j)/q;
                   
                end
			end
			
			QEnc  =round(QEnc);
            
 %%%%%%%%%%%%%%%%%%%%% zig zag scanning
		ZQEnc = Zigzag(QEnc);
                     
       		

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% huffman encoder
Level=8;
Speed=0;
xC=cell(1,1);
xC{1}=ZQEnc;
% xC{2}=mm;

[y, Res]=Huff06(xC, Level, Speed);
           				
save y y;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Bitstream{j1}=y;
cc=length(y);
% cc=cc;
dd=cc;
Bitst(j1)= dd;
j1=j1+1;

end

%  close(h)

toc;
  Compresed_file_size = sum(Bitst);
% Compresed_file_size=Compresed_file_size;

 Comp_RATIO= Input_filesize/Compresed_file_size;
 save Comp_RATIO Comp_RATIO;
          

enctime=toc;
set(handles.enc,'String',enctime);
handles.enctime=enctime;
handles.Image1 = Image1;
save Bitstream;
% Update handles structure
guidata(hObject, handles);

handles.r =r;
handles.c =c;
            helpdlg('Encoding Completed');
% --- Executes on button press in output.
function output_Callback(hObject, eventdata, handles)
% hObject    handle to output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.

function Decoding_Callback(hObject, eventdata, handles)
% hObject    handle to Decoding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

q=1;
n=[];
%%%%%%%%%%%%%%%%%%%%%%%%%% load bitstream
load Bitstream;
% load target;
% n{1}=double(target);
% Bitstream{1}=double(target);
 q=1; %%%%%%%%%%%%%%%% quantization value
 A2='.bmp';
 [r2 c2]=size(Bitstream);%%%%%%%%%%%%%%%% find the size of the bitstream
 Length=c2;
%r = handles.r;
%c = handles.c;
row=handles.row;
col=handles.col;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% huffman decoder
  tic;
%  for i=1:10
%      A1=num2str(i);
 y= Bitstream{1};
 xR=Huff06(y);
 
            v=xR{1};

			ZQEnc=v;
		
		%%%%%%%%%%%%%%%%%%%%%%%%% INVERSE ZIG ZAG
		
		
		y = ZigzagInv(ZQEnc,r,c);
		
		
		QEnc=y;
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%UNIFORM QUANTIZATION
% 		q=10;
		Enc=QEnc*q;
		
		
		%%%%%%%%%%%%%%%%%%%%%   IDCT
		
		%Output_Image = myIDCT(Enc);
        Output_Image = waverec2(Enc,s,'sym4');
		out = Iacc(Output_Image,1);
        %imshow(out);

		output = out(:,:,1);
%  filename=strcat(A1,A2);
%   filename1=strcat(A1,A2);
%  figure;
%%%%%%%%%%%%%%%%%%%%%%%%%%%change the directory for Reconstruction
cd 'output'
for i = 1 : 8
   
    aa=uint8(Output_Image);
    aa=uint8(out);
    
    row=handles.row;
    col=handles.col;
%     aa=imresize(aa,[120 120]); %%%%%%%%%%% resize into original file
    out1 = aa(:,:,i);
%     aa = imread(filename);
    filename = num2str(i);
    filename = strcat(filename,A2);
    imwrite(out1,filename); %%%%%%%%%%%%%% store it as an image;
    %  imshow(aa,[]);
end
 cd  ..
  
% end
toc;

dectime=toc;
set(handles.dec,'String',dectime);
handles.dectime=dectime;

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd ..
fprintf('\ndectime: %7.2f ', dectime)
%%%%%%%%%%%%%%%%%%%%%%%% to find psnr
% input = handles.Image1;

% % % % % % % % % % % % % % % to find MSE
input1 = imread('1.bmp');
input1 = imresize(input1,[120,120]);
input1 = double(input1);
output = double(output);
[M N] = size(input1);
MSE = sum(sum((input1 - output)^2))/(M*N);
MSE = MSE/100000;
set(handles.mse,'String',MSE);

% % % % % % % % % % % % % % to find PSNR
PSNR = (10 * log10(255*255)/MSE)-120;
set(handles.psnr,'String',PSNR);
warndlg('Decoding completed');


% --- Executes on button press in Browse_comVideo.
function Browse_comVideo_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_comVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Embedding.
function Reconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to Reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frm_cnt=4;
number_of_frames=frm_cnt;
filetype='.bmp';
display_time_of_frame=1;
cd 'output'
frm_cnt=4;
number_of_frames=frm_cnt;
filetype='.bmp';
%display_time_of_frame=1;
mov = avifile('MOVIE');
count=0;
for i=1:number_of_frames
    name1=strcat(num2str(i),filetype);
    a=imread(name1);
    while count<display_time_of_frame
        count=count+1;
        imshow(a);
        F=getframe(gca);
        mov=addframe(mov,F);
    end
    count=0;
end
mov=close(mov);
cd ..


% --- Executes on button press in Extraction.
function no_CreateFcn(hObject, eventdata, handles)
% hObject    handle to no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function no_Callback(hObject, eventdata, handles)
% hObject    handle to no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of no as output
%        str2double(get(hObject,'String')) returns contents of no as a double


% --- Executes during object creation, after setting all properties.
function mse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function mse_Callback(hObject, eventdata, handles)
% hObject    handle to mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mse as output
%        str2double(get(hObject,'String')) returns contents of mse as a double


% --- Executes during object creation, after setting all properties.
function psnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function psnr_Callback(hObject, eventdata, handles)
% hObject    handle to psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psnr as output
%        str2double(get(hObject,'String')) returns contents of psnr as a double


% --- Executes during object creation, after setting all properties.
function enc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function enc_Callback(hObject, eventdata, handles)
% hObject    handle to enc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enc as output
%        str2double(get(hObject,'String')) returns contents of enc as a double


% --- Executes during object creation, after setting all properties.
function dec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dec_Callback(hObject, eventdata, handles)
% hObject    handle to dec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dec as output
%        str2double(get(hObject,'String')) returns contents of dec as a double


% --- Executes during object creation, after setting all properties.
function n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function n_Callback(hObject, eventdata, handles)
% hObject    handle to n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n as output
%        str2double(get(hObject,'String')) returns contents of n as a double


% --- Executes during object creation, after setting all properties.
function e_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function e_Callback(hObject, eventdata, handles)
% hObject    handle to e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e as output
%        str2double(get(hObject,'String')) returns contents of e as a double


% --- Executes during object creation, after setting all properties.
function d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function d_Callback(hObject, eventdata, handles)
% hObject    handle to d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d as output
%        str2double(get(hObject,'String')) returns contents of d as a double


% --- Executes during object creation, after setting all properties.
function key_CreateFcn(hObject, eventdata, handles)
% hObject    handle to key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function key_Callback(hObject, eventdata, handles)
% hObject    handle to key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of key as output
%        str2double(get(hObject,'String')) returns contents of key as a double

function out = acc(curr_frame)
%str1 = filename_1;
type = '.bmp';
blocksize=8;
% sample = imread(filename_1);
% [row col plane] = size(sample);
out = zeros(120,120*blocksize);

h = waitbar(0,'Please wait...');
% for j=1:8:2048
    for i=1:blocksize:120
        waitbar(i/120,h)
        j=1;
        for l=1:blocksize:120
           for L=l:l+7
                rev=0;
            for k=curr_frame:curr_frame+7
                %str1= 'missa.org';
%                 if i==1 && j==960
%                    i
%                    j
%                 end
                file = num2str(k);
                file = strcat(file,type);
                input = imread(file);
                gry = imresize(input,[120 120]);
%                 gry = rgb2gray(a);
                if mod(l,blocksize)~=0
                   out(i:i+7,j) = gry(i:i+7,L);
                else 
                   out(i:i+7,j) = gry(i:i+7,L+7-rev);
                end
                j=j+1;
                rev = rev+1;
                
                
            end
          end % for L
       end   %for l
    end% for i
   imwrite(uint8(out),strcat(num2str(curr_frame),'.jpg'));
%    fclose(h);
% end
figure;imshow(out,[]);



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mse as text
%        str2double(get(hObject,'String')) returns contents of mse as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psnr as text
%        str2double(get(hObject,'String')) returns contents of psnr as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


