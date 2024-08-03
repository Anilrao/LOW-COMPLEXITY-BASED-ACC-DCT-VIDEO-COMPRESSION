function out = acc(curr_frame)
%str1 = filename_1;
type = '.bmp';
blocksize=8;
% sample = imread(filename_1);
% [row col plane] = size(sample);
out = zeros(64,64*blocksize);

% for j=1:8:2048
    for i=1:blocksize:64
        j=1;
        for l=1:blocksize:64
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
                gry = imresize(input,[64 64]);
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
% end
figure;imshow(out,[]);