function asr = asrresults_read(filename, dem)
% asr = asrresults_read(filename, dem)
%   Read a Babel ctm.sys resultss file.  Return
%   asr.{uttID,snt,chr,corr,sub,del,ins,err,serr}
%   each as cell arrays with corresponding entries per file.
%   Returns actual counts (integers), not rates.
%   If provided, dem is a struture from demographics_read which is
%   linked to asr results lines.
% 2014-01-03 Dan Ellis dpwe@ee.columbia.edu

if nargin < 2; dem = []; end

if exist(filename, 'file') == 0
  disp(['ASR results file ', filename,' not found']);
  asr.uttID = cell(0);
  return;
end


fp = fopen(filename, 'r');

ix = 0;

rlsts = [];

nfields = 9;  % or 10 if NCE column included

while feof(fp) == 0

  line = fgetl(fp);
  if length(line) > 2
    if line(1) == '|'
      flds = regexp(line,'([A-z0-9\.]+)','match');
      if length(flds) > 0 && strcmp(flds{1}, 'SPKR') == 1
        if length(flds) == 10 && strcmp(flds{10}, 'NCE') == 1
          nfields = 10;
        end
      else
        if length(flds) == nfields  ... % to skip non-result lines
            && strcmp(flds{1}, 'Sum/Avg') == 0 ...
            && strcmp(flds{1}, 'Mean') == 0 ...
            && strcmp(flds{1}, 'S.D.') == 0 ...
            && strcmp(flds{1}, 'Median') == 0
          ix = ix + 1;
          asr.uttID{ix}  = flds{1};
          snt    = str2num(flds{2});
          chr    = str2num(flds{3});
          asr.snt(ix)    = snt;
          asr.chr(ix)    = chr;
          asr.corr(ix)   = round(chr/100*str2num(flds{4}));
          asr.sub(ix)    = round(chr/100*str2num(flds{5}));
          asr.del(ix)    = round(chr/100*str2num(flds{6}));
          asr.ins(ix)    = round(chr/100*str2num(flds{7}));
          asr.err(ix)    = round(chr/100*str2num(flds{8}));
          asr.serr(ix)   = round(snt/100*str2num(flds{9}));
        end
      end
    end
  end

end

fclose(fp);

% Maybe link demographics info
if length(dem)
  % join to asrresults

  for i = 1:length(asr.uttID)
    ix = strmatch(lower(asr.uttID{i}), dem.outputFn);
    asr.demIndex(i) = ix;
    asr.envTypeCode(i) = dem.envTypes.code(ix);
    asr.dialectCode(i) = dem.dialectCodes.code(ix);
    asr.gender(i) = dem.genders.code(ix);
    asr.network(i) = dem.networks.code(ix);
  end
  % record the names
  asr.envTypeNames = dem.envTypes.abbrev;
  asr.dialectNames = dem.dialectCodes.names;
  asr.genderNames = dem.genders.names;
  asr.networkNames = dem.networks.names;
  
end
