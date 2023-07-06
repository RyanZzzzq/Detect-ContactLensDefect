%% ��������
% @file ��Detect_ContactLensDefect.m�� 
% @brief ��ʹ��ͼ��ʶ�������������۾�ͼƬ��Եȱ�ݽ��м�Ⲣ��ʶ��
% @version 1.0 ���汾������
% @author ��RyanZzzq��
% @date ��2023.7.6��

%% ��ʼ��
close all; 
clear all; 
clc;

%% ��ȡͼƬ��תΪ�Ҷ�ͼ
mI = double( imread( './3.png' ) );  
mI = mI( :, :, 1 );
figure; 
subplot( 1, 2, 1 ); 
imagesc( mI ); 
axis image; 
colormap( gray );       %ת���ɻҶ�ͼ
title( 'Contact Lens' );  

%% ��ȡͼƬ�߶ȺͿ��
[ H, W ] = size( mI ); 

mVEdge = zeros( H, W ); 


%% ��ƽ��λ�ô������������Դ˽�����һ������
for i = 2 : H
    mVEdge( i, : ) = mI( i, : ) - mI( i - 1, : );
end
figure; imagesc( mVEdge ); axis image; colormap( gray ); title( 'Vertical Edge' );  %��ֱ��Ե

mHEdge = zeros( H, W );
for i = 2 : W
    mHEdge( :, i ) = mI( :, i ) - mI( :, i - 1 );
end
figure; imagesc( mHEdge ); axis image; colormap( gray ); title( 'Horizontal Edge' ); %ˮƽ�߱�Ե

mEuclidEdge = sqrt( mVEdge .* mVEdge + mHEdge .* mHEdge );
mCombinedEdge = ( mVEdge .* mVEdge + mHEdge .* mHEdge );
figure; imagesc( mCombinedEdge ); axis image; colormap( gray ); title( 'Euclid Edge' );  %ŷ����ñ�Ե

Th = max( mCombinedEdge( : ) ) / 5;
mBinaryEdge = zeros( H, W );
vEdgeIdx = find( mCombinedEdge > Th );
mBinaryEdge( vEdgeIdx ) = 1;
figure; imagesc( mBinaryEdge ); axis image; colormap( gray ); title( 'Binary Edge' );  %��ά��Ե

vX = floor( ( vEdgeIdx - 1 ) / H ) + 1;
vY = mod( vEdgeIdx - 1, H ) + 1;
figure; plot( vX, vY, '.' ); axis image;

vB = vX .* vX + vY .* vY;
mA = [ ones( length( vEdgeIdx ), 1 ), 2 * vX, 2 * vY ];
vS = mA \ vB;
X0 = vS( 2 );
Y0 = vS( 3 );
Radius = sqrt( vS( 1 ) + X0 * X0 + Y0 * Y0 );
hold on; plot( X0, Y0, 'ro' );

vDiff = abs( Radius - sqrt( ( vX - X0 ) .^ 2 + ( vY - Y0 ) .^ 2 ) );  %��뾶֮��ľ���ֵ
vDefectIdx = find( vDiff > 2 );
vDefectX = vX( vDefectIdx );
vDefectY = vY( vDefectIdx );

%% ��ʾʶ����
figure( 1 ); 
subplot( 1, 2, 2 ); 
imagesc( mI ); 
axis image; 
colormap( gray ); 
title( 'Detected defects' );
hold on; 
plot( vDefectX, vDefectY, 'ro' );
