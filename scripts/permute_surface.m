function permute_surface(subject_id, permno, data_dir)

subject_id = num2str(subject_id);
permno = num2str(permno);
permno = str2num(permno);

left_surf_file = sprintf('%sSurfaces/%s.L.sphere.32k_fs_LR.surf.gii', data_dir, subject_id);
surfl = gifti(left_surf_file);
verticesl = surfl.vertices;
datal = 1:size(verticesl, 1);

right_surf_file = sprintf('%sSurfaces/%s.R.sphere.32k_fs_LR.surf.gii', data_dir, subject_id);
surfr = gifti(right_surf_file);
verticesr = surfr.vertices;
datar = 1:size(verticesr, 1);

I1 = eye(3,3);
I1(1,1)=-1;
bl=verticesl;
br=verticesr;

distfun = @(a,b) sqrt(bsxfun(@minus,bsxfun(@plus,sum(a.^2,2),sum(b.^2,1)),2*(a*b)));

rot_dir = sprintf('%sSurfacePermutations/Rotations', data_dir);
subj_dir = sprintf('%sSurfacePermutations/%s', data_dir, subject_id);

if ~exist(subj_dir, 'dir')
    mkdir(subj_dir);
end

for j = 1:permno
    
    rotl_file = sprintf('%s/Rotation.L.%i.mat', rot_dir, j);
    load(rotl_file)
    
    rotr_file = sprintf('%s/Rotation.R.%i.mat', rot_dir, j);
    load(rotr_file)

    bl =bl*TL;
    br = br*TR;

    left_suffix = sprintf('%s.L.sphere.32k_fs_LR.Rotation.%i.mat', subject_id, j);
    right_suffix = sprintf('%s.R.sphere.32k_fs_LR.Rotation.%i.mat', subject_id, j);
    left_out = sprintf('%s/%s', subj_dir, left_suffix);
    right_out = sprintf('%s/%s', subj_dir, right_suffix);

    save(left_out, 'bl', '-v7.3');
    save(right_out, 'br', '-v7.3');
    
    %Find the pair of matched vertices with the min distance and reassign
    %values to the rotated surface.
    distl=distfun(verticesl, bl');
    distr=distfun(verticesr, br');
    [~, Il]=min(distl, [], 2);
    [~, Ir]=min(distr, [], 2);
    
    %save rotated data
    rotl = datal(Il)';
    rotr =  datar(Ir)';
    
    left_suffix = sprintf('%s.L.Indices.Rotation.%i.mat', subject_id, j);
    right_suffix = sprintf('%s.R.Indices.Rotation.%i.mat', subject_id, j);
    left_out = sprintf('%s/%s', subj_dir, left_suffix);
    right_out = sprintf('%s/%s', subj_dir, right_suffix);

    save(left_out, 'rotl', '-v7.3');
    save(right_out, 'rotr', '-v7.3');
    
end