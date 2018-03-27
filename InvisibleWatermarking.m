% The Following program uses Binary Image as Watermark image.
% Other forms of image cannot be decrypted using this program but the program can be modified to include other forms
% of image.


% Invisible Image Watermarking Using DWT-DCT
% Simple Subtraction Embedding Algorithm used to embed watermark image.


clc;
close all;
clear all;

% Importing Host Image..

HostImage=imread('cameraman.tif');

HostImage=imresize(HostImage,[510 510]);

figure();
imshow(HostImage);
title('Host Image');

% performing DWT on Image

[LL1,LH1,LV1,LD1]=dwt2(HostImage,'db2');


% Splitting LH component image into 8*8 blocks
xyz=1;

for i=1:8:256
    for j=1:8:256
        
        
            
         for x=0:7
             u=i+x;
             v=1;
             for y=0:7
              
             v=j+y;
             
             newmat{1,xyz}(x+1,y+1)= LH1(u,v);
               
              end
         end
        
        xyz=xyz+1;
    end
end

% performing DCT on 8*8 Blocks

for x=1:1024
    dct{1,x}=dct2(newmat{1,x});    
end

dcttt=dct;

% extracting Dc component of each 8*8 block and forming a vector out of it 

for x=1:1024
    
    DCvector(x)=dct{1,x}(1,1);
    
end
x=1;
% converting the Dc component vector to a 32*32 Matrix.
for i=1:32
    for j=1:32
        
        DCmatrix(i,j)=DCvector(x);
        x=x+1;
        
    end 
end

% Importing Watermarking Image

watermarkImage1=checkerboard(5);

WaterMarkImage=imresize (watermarkImage1,[32,32]);

figure();
imshow(WaterMarkImage);
title('Watermark Image');


% Encryption Of Image Begins.

% Converting Image into vector Of 0's And 1's
l=1;
for i=1:32
    for j=1:32
        VectOfWatermark(l)=uint8(WaterMarkImage(i,j));
        l=l+1;
    end
end

% Creating a Psuedo-Random Sequence

for i=1:1024
    pnseed=[1 0 1 0 1 0 1 0];
    if i<=8                                 
        pnseq(i)=pnseed(i);
   
    else
        pnseq(i)=xor(pnseq(i-2),pnseq(i-6));
        
    end
end

% Generating a Highly Chaotic sequence using Logistic Map Function

for i=1:1023
    
    lmp(1)=0.5;
    lmp(i+1)=lmp(i)*3.99*(1-lmp(i));
    lmp=uint8(lmp);
    
end
% Generating Key using Pnseqence and Chaotic sequence

Key=xor(pnseq,lmp);

% Encrypting Watermark Image using Key

Encryptedimage=xor(Key,VectOfWatermark);



EncryptedImageVector=double(Encryptedimage);
x=1;
% converting encrypted Image vector into Matrix
for i=1:32
    for j=1:32
        EncryptedImage(i,j)=EncryptedImageVector(x);
        x=x+1;
    end
end

figure();
imshow(EncryptedImage);
title('Encrypted Watermark Image');

    % Embedding the Encrypted image onto the Dc Component Matrix
    
NewDcdctMatrix=DCmatrix-EncryptedImage;

 
% Converting the Embedded Matrix to Vector
x=1;

for i=1:32
    for j=1:32
        NewDcdctVector(x)=NewDcdctMatrix(i,j);
        x=x+1;
    end
end

% Inserting the Dc values back into the Dct 8*8 matrix blocks 

for x=1:1024
    dct{1,x}(1,1)=NewDcdctVector(x);
end

% Taking Inverse Dct of the embedded 8*8 blocks

for x=1:1024
    
    NewMatPieces{x}=idct2(dct{1,x});
    
end

% Rejoining the embedded 8*8 blocks to form new LH component
x=1;
for i=1:8:256
    q=i;
    for j=1:8:256
        
          z=j;

        for p=0:7
           
            
            for a=0:7
                
                
                
                NLH1(i,j)=NewMatPieces{1,x}(p+1,a+1);
                j=j+1;
                   
            end
            i=i+1;
            j=z;
        end
        i=q;
        x=x+1;
     end
end

% Taking IDWT using the new LH component and thus obtaining the watermarked image.
WatermarkedImage=idwt2(LL1,NLH1,LV1,LD1,'db2');
figure();
imshow(uint8(WatermarkedImage));
title('Watermarked Image');


% Extraction Of WaterMark


% Taking Dwt of Received Watermarked Image
[WLL,WLH,WLV,WLD]=dwt2(WatermarkedImage,'db2');

% Splitting the LH component of the watermarked image to 8*8 blocks
xyz=1;
u=0;
v=0;
for i=1:8:256
    for j=1:8:256
        
        
            
         for x=0:7
             u=i+x;
             v=1;
             for y=0:7
              
             v=j+y;
             
             newwatermat{1,xyz}(x+1,y+1)= WLH(u,v);
               
              end
         end
        
        xyz=xyz+1;
    end
end

% Taking dct of 8*8 blocks
for x=1:1024
    dctwmmat{1,x}=dct2(newwatermat{1,x});    
end

% Constructing vector of DC components of dct of 8*8 blocks

for x=1:1024
    
    DCwmvector(x)=dctwmmat{1,x}(1,1);
    
end

% Constructing matrix using the vector of Dc components

x=1;
for i=1:32
    for j=1:32
        
        DCwmmatrix(i,j)=DCwmvector(x);
        x=x+1;
        
    end 
end

% Extracting the embedded encrypted watermark image
ExtractedWatermarkImage=-DCwmmatrix+DCmatrix;   

figure();

imshow(ExtractedWatermarkImage);

title('Extracted Encrypted Watermark Image');

% Decryption Of Extracted Watermark.

% Constructing vector of 0's and 1's of the extracted encrypted image

l=1;
for i=1:32
    for j=1:32
        VectOfRWatermark(l)=uint8(ExtractedWatermarkImage(i,j));
        l=l+1;
    end
end

% Decrypting the vector using the key
VectOfRImage=xor(Key,VectOfRWatermark);

x=1;

% Forming matrix of the Decrypted vector
for i=1:32
    for j=1:32
        
        DecryptedWaterMarkImage(i,j)=VectOfRImage(x);
        x=x+1;
        
    end 
end

figure();
imshow(DecryptedWaterMarkImage);
title('Decrypted Form Of Extracted Watermark Image');

% END


            
            





