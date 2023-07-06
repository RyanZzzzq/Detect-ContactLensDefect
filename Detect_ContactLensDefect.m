%% 代码描述
% @file （Detect_ContactLensDefect.m） 
% @brief （使用图像识别技术，对隐形眼镜图片边缘缺陷进行检测并标识）
% @version 1.0 （版本声明）
% @author （RyanZzzq）
% @date （2023.7.6）

%% 初始化
close all; 
clear all; 
clc;

%% 读取图片并转为灰度图
mI = double( imread( './3.png' ) );  
mI = mI( :, :, 1 );
figure; 
subplot( 1, 2, 1 ); 
imagesc( mI ); 
axis image; 
colormap( gray );       %转换成灰度图
title( 'Contact Lens' );  

%% 获取图片高度和宽度
[ H, W ] = size( mI ); 

mVEdge = zeros( H, W ); 


%% 在平铺位置创建坐标区，以此进行下一步操作
for i = 2 : H
    mVEdge( i, : ) = mI( i, : ) - mI( i - 1, : );
end
figure; imagesc( mVEdge ); axis image; colormap( gray ); title( 'Vertical Edge' );  %垂直边缘

mHEdge = zeros( H, W );
for i = 2 : W
    mHEdge( :, i ) = mI( :, i ) - mI( :, i - 1 );
end
figure; imagesc( mHEdge ); axis image; colormap( gray ); title( 'Horizontal Edge' ); %水平线边缘

mEuclidEdge = sqrt( mVEdge .* mVEdge + mHEdge .* mHEdge );
mCombinedEdge = ( mVEdge .* mVEdge + mHEdge .* mHEdge );
figure; imagesc( mCombinedEdge ); axis image; colormap( gray ); title( 'Euclid Edge' );  %欧几里得边缘

Th = max( mCombinedEdge( : ) ) / 5;
mBinaryEdge = zeros( H, W );
vEdgeIdx = find( mCombinedEdge > Th );
mBinaryEdge( vEdgeIdx ) = 1;
figure; imagesc( mBinaryEdge ); axis image; colormap( gray ); title( 'Binary Edge' );  %二维边缘

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

vDiff = abs( Radius - sqrt( ( vX - X0 ) .^ 2 + ( vY - Y0 ) .^ 2 ) );  %求半径之差的绝对值
vDefectIdx = find( vDiff > 2 );
vDefectX = vX( vDefectIdx );
vDefectY = vY( vDefectIdx );

%% 显示识别结果
figure( 1 ); 
subplot( 1, 2, 2 ); 
imagesc( mI ); 
axis image; 
colormap( gray ); 
title( 'Detected defects' );
hold on; 
plot( vDefectX, vDefectY, 'ro' );
