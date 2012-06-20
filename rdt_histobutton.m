function [] = rdt_histobutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;

secondcode = rdt_ecodes( 2 );

%    prompt={ sprintf( 'Generate histograms for all trials with code %d.\nEnter one or more alignment codes \n(codes on which the data will be aligned):', secondcode )...
%             'miliseconds before alignment time to gather spike data:',...
%             'miliseconds after alignment time to gather spike data:',...
%             'Bin width for histogram (leave blank for 20ms):',...
%             'Initial sigma for density functions (blank for 5ms):',...
%             'Type a 1 to include BAD trials:' };
prompt={    'Generate histograms for all trials with code:',...
            'Enter one or more alignment codes (codes on which the data will be aligned):', ...
            'miliseconds before alignment time to gather spike data:',...
            'miliseconds after alignment time to gather spike data:',...
            'Bin width for histogram (leave blank for 20ms):',...
            'Initial sigma for density functions (blank for 5ms):',...
            'Type a 1 to include BAD trials:' };
        
   name='Alignment codes for PETH';
   %numlines=1;
   %defaultanswer={'20','hsv'};
 
   defaultanswer = {num2str(secondcode), '', '1000', '500', '20', '5', ''};
   answer=inputdlg(prompt,name,1,defaultanswer);
   if isempty( answer )
       return;
   end;
 
   for d=3:7
       if isempty( answer{d} )
           answerint(d) = 0;
       else
           answerint(d) = str2num( answer{d} );
       end;
   end;
   
   secondcode = str2num( answer{ 1 } );
   if isempty( secondcode ) %|| (secondcode == 0)
       return;
   end;
       
   aligncodes = str2num( answer{ 2 } );
   if isempty( aligncodes ) %|| (aligncodes == 0)
       return;
   end;
   
   mstart = answerint( 3 );
   if mstart == 0
       mstart = 1000;
   elseif mstart < 0
       mstart = mstart * -1.0;        
   end;
   mstop = answerint( 4 );
   if mstop == 0
       mstop = 500;
   end;
   
   binwidth = answerint(5);
   if binwidth <= 0
       binwidth = 20;
   end;
   
   fsigma = answerint( 6 );
   if fsigma == 0
       fsigma = 5;
   end;

   includebad = answerint(7);
   
    wb = waitbar( 0.1, 'Generating rasters...' );
    
    [r,aidx,eyeh,eyev,eyevel] = rex_rasters_trialtype( rdt_filename, 1, secondcode, [],[],aligncodes, includebad);

    if isempty( r )
        disp( 'No raster could be generated (rex_rasters_trialtype returned empty raster)' );
        close( wb );
        return;
    end;
    
    start = aidx - mstart;
    stop = aidx + mstop;
    if start < 1
        start = 1;
    end;
    if stop > length( r )
        stop = length( r );
    end;
    
%     aidx
%     start
%     stop
%     
    figure( 20 );
    imagesc( fat_raster(r, 3) );
    
    starth = ceil( start / binwidth );
    stoph = floor( stop / binwidth );
    
    sz = size( r );
    trials = sz( 1 );
    h = spikehist( r, binwidth );    
    sumall = merge_raster( r( :, start:stop ) );
    waitbar( 0.3, wb, 'Calculating spike density...' );
    sdf = spike_density( sumall, fsigma ) ./ trials;
    waitbar( 0.6, wb, 'Calculating probability density...' );
    pdf = probability_density( sumall, fsigma ) ./ trials;
%     pdf = [];
    waitbar( 0.9, wb, 'Plotting...' );


    
    invgray = gray;
    figure()
    subplot( 3,1, 1 );
    fat = fat_raster( r, 1 );
    imagesc( fat(:,start:stop) );
    for i=1:size(fat,1)
        spkcntstr=sprintf('number of spikes in trial %d is %d',i, length(find(fat(i,start:stop))));
        disp(spkcntstr);
    end
    colormap( 1-gray );


    ax1 = axis();
    sz = size( r );
%     if length( secondcode ) > 1 || length( aligncodes ) > 1
%         s1 = sprintf( '%s spike raster, Code %d etc., n = %d trials, aligned to %d etc.', rdt_filename, secondcode(1), sz( 1 ), aligncodes );
%     else
        s1 = sprintf( '%s spike raster, Code %s, n = %d trials, aligned to %s', rdt_filename, num2str( secondcode ), sz( 1 ), num2str( aligncodes ) );
%     end;
    title( s1 );
%     subplot( 3, 1, 2 );
%     bar( h(starth:stoph), 'k' );
%     title( 'spike histogram' );
%     ax2 = axis();
%     ax2(2) = ceil( ax1(2) / binwidth );
%     axis( ax2 );
    subplot( 3, 1, 2 );
    plot( sdf );
    ax3 = axis();
    alignmarker = sdf .* 0;
    alignmarker( aidx-start ) = ax3(4);
    hold on;
    plot( alignmarker, 'r' );
    hold off;
    title( 'spike density function ' );
    ax3 = axis();
    ax3(2) = ax1(2);
    axis( ax3 );
    subplot( 3,1, 3 );
    sz = size( eyevel );
    if sz(2) >= stop
        plot( eyevel( :, start:stop)' );
        hold on;
        meanvel = mean( eyevel( :, start:stop ) );
        plot( meanvel, 'k-', 'LineWidth', 2 );
        hold off;
     end;
     title( 'eye velocity' );
     axis( 'tight' );
%     plot( pdf );
%     title( 'probability density function (adaptive)' );
%     ax4 = axis();
%     ax4(2) = ax1(2);
%     axis( ax4 );
    
%     figure;
%     plot( pdf );
%     hold on;
%     plot( alignmarker, 'r' );
%     hold off;
%     axis( ax4 );
    
    close( wb );
    
    