% 
% Script to run the short-term prediction experiment 
% This simply uses the next image in the album for 
% all images in the test albums.
% This script contains the Random and NN baselines in 
% addition to SRNN
%
% Gunnar Atli Sigurdsson & Xinlei Chen 2015
% Carnegie Mellon University

datadir = '/nfs/onega_no_backups2/users/gsigurds/storylines_data/';
nextsrnn = cell(49,9,10,4);
nextrand = cell(49,9,10,4);
nextnn = cell(49,9,10,4);
for choice = 1:4
if choice==1
disp('paris')
load([datadir,'test_paris.mat']);
load('paris10model.mat');
elseif choice==2
disp('wedding')
load([datadir,'test_wedding.mat']);
load('wedding10model.mat');
elseif choice==3
disp('christmas')
load([datadir,'test_christmas.mat']);
load('christmas10model.mat');
elseif choice==4
disp('london')
load([datadir,'test_london.mat']);
load('london10model.mat');
else
    disp('ERROOR')
    return;
end
    
%rng(321); %fixed seed
[s1,s2] = RandStream.create('mrg32k3a','NumStreams',2,'Seed',321);
RandStream.setGlobalStream(s2);
%if ~(matlabpool('size') > 0)
%    matlabpool(4); 
%end
%parfor i = 1:length(A)
for i = 1:length(A)
    for j = 1:9
    %fprintf('%d ',i);
    for repeat = 1:1 % over multiple folds
    example = A{i};
    urls = S{i};

    % simplification of a more general setup that used multiple previous ones
    prevind = randi(s1,size(example,1)-1);

    % next one
    mid = prevind+1;

    % define the output space to be random choices but not the next one, mid
    n = 4;
    choiceinds = setdiff(1:size(example,1),[prevind mid]);
    choiceinds = choiceinds(randperm(s1,length(choiceinds),n));
    % for code simplicity correct always last. Make sure method is not biased by shuffling inside method
    choiceinds = [choiceinds mid]; 
    shuffle = randperm(s1,length(choiceinds));
    choiceinds = choiceinds(shuffle);
    correct = find(choiceinds==mid);

    examplechoices = example(choiceinds,:);
    urlschoices = urls(choiceinds);
    exampleprev = example(prevind,:);
    urlsprev = urls(prevind);

    %methods
    srnnel = next_srnn(net,examplechoices,exampleprev);
    randsel = randi(size(examplechoices,1));
    [~,nnsel] = min(pdist2(examplechoices, exampleprev, 'cosine'));

    % check if right prediction
    nextsrnn{i,j,repeat,choice} = srnnel == correct;
    nextrand{i,j,repeat,choice} = randsel == correct;
    nextnn{i,j,repeat,choice} = nnsel == correct;

end
end
end

nextsrnn2 = reshape(nextsrnn(:,:,:,choice),[],1);
nextrand2 = reshape(nextrand(:,:,:,choice),[],1);
nextnn2 = reshape(nextnn(:,:,:,choice),[],1);

fprintf('\n');
fprintf('srnn: %g\n', mean(cell2mat(nextsrnn2(~cellfun('isempty',nextsrnn2)))));
fprintf('rand: %g\n', mean(cell2mat(nextrand2(~cellfun('isempty',nextrand2)))));
fprintf('  nn: %g\n', mean(cell2mat(nextnn2(~cellfun('isempty',nextnn2)))));
fprintf('\n');

end

nextsrnn = reshape(nextsrnn(:,:,:),[],1);
nextrand = reshape(nextrand(:,:,:),[],1);
nextnn = reshape(nextnn(:,:,:),[],1);

fprintf('\n');
fprintf('srnn: %g\n', mean(cell2mat(nextsrnn(~cellfun('isempty',nextsrnn)))));
fprintf('rand: %g\n', mean(cell2mat(nextrand(~cellfun('isempty',nextrand)))));
fprintf('  nn: %g\n', mean(cell2mat(nextnn(~cellfun('isempty',nextnn)))));


