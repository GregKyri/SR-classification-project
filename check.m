% TT=[]
for ii=1:605%size(U,1)
if length(Input{ii,1}.(1))>=60
    for iii=1:length(Input{ii,1}.(1))
      if iii>12 && Input{ii,1}.(4)(iii)==Input{ii,1}.(4)(iii-12)
      Input{ii,1}.FreeCl_1(iii)=Input{ii,1}.(8)(iii-12);
      Input{ii,1}.TotalCl_1(iii)=Input{ii,1}.(12)(iii-12);
      else
      Input{ii,1}.FreeCl_1(iii)=nan;
      Input{ii,1}.TotalCl_1(iii)=nan;
        end
    end
else
    Input{ii,1}.FreeCl_1(iii)=nan;
    Input{ii,1}.TotalCl_1(iii)=nan;
end
Input{ii,1}=movevars(Input{ii,1},'index','after','TotalCl_1');
end

% for ii=1:size(U,1)
%     for iii=2013:2021
%         for iv=1:12
% if Input{ii,1}.(3)==iii && Input.(4)==iv
%     Input{ii,1}.(18)==Input{ii,1}.(8)

% X = zeros(size(u));
% for k = 1:numel(t)
%     X(strncmp(u,t{k},3)) = k;
% end
% s=unique(SR.(11));
% srwtw=ismember(s,t);
% srwtw=rmmissing(srwtw);
% ss=find(srwtw==0);
% srwtw=s(ss);
% srwtw=rmmissing(srwtw);
% ind=find(SR.(11)=="STAFFIN WTW 1960 NG459683");
% SR.(11)(ind)={wtwsr{88,1}};

% ind=find(SR.(11)=={srwtw{3,1}});
% SR.(11)(ind)={t{26,1}};
