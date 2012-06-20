function arecs = rex_arecs(name)

mlock;

persistent s2l;
persistent sa2la;

if isempty(sa2la)

    s2l = inline('double(uint8(s(1)))+256*double(uint8(s(2)))','s');
    sa2la = inline('double(uint8(s(:,1)))+256.*double(uint8(s(:,2)))','s');
    
end;

d = load_rex_hdr(name);

if ~isempty(d)
    
    x = 1;
    max_num_sig = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    frm_arry_sz = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    max_calib = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    name_len = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    num_sig = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    max_samp_rate = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    min_samp_rate = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    num_subframe = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    num_frame = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    mast_frame_dur = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    sig_in_frm = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    sig_in_mast_frm = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    num_a_d_chan = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    a_d_res = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    a_d_radix_comp = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    a_d_ov_gain = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    datum_size = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_a_d_rate = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_store_rate = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_a_d_calib = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_shift = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_gain = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_a_d_delay = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_a_d_chan = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_frame = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_gvname = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_title = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_calibst = s2l([d((2*x)-1),d(2*x)]);
    
    x = x + 1;
    offset_data = 2*x-1;
    
    x = offset_data + offset_a_d_rate + 2*(1:max_num_sig) - 2;
    a_d_rate = sa2la([d(x),d(x+1)]);
        
    x = offset_data + offset_store_rate + 2*(1:max_num_sig) - 2;
    store_rate = sa2la([d(x),d(x+1)]);
    
    x = offset_data + offset_a_d_calib + 2*(1:max_num_sig) - 2;
    a_d_calib = sa2la([d(x),d(x+1)]);
    
    x = offset_data + offset_shift + 2*(1:max_num_sig) - 2;
    shift = sa2la([d(x),d(x+1)]);
    
    x = offset_data + offset_gain + 2*(1:max_num_sig) - 2;
    gain = sa2la([d(x),d(x+1)]);
    
    x = offset_data + offset_a_d_delay + 2*(1:max_num_sig) - 2;
    a_d_delay = sa2la([d(x),d(x+1)]);
    
    x = offset_data + offset_a_d_chan + 2*(1:max_num_sig) - 2;
    a_d_chan = sa2la([d(x),d(x+1)]);
    
    x = offset_data + offset_frame + 2*(1:frm_arry_sz) - 2;
    frm_arry = s2l([d(x),d(x+1)]);
    
    gvname = {};
    for r = 1:max_num_sig
        x = offset_data + offset_gvname + name_len*(r-1);
        gvname{r} = (d(x:(x+ name_len-1)))';
        gvname{r} = char(gvname{r});   
    end;  % looping through gvname
    
    title = {};
    for r = 1:max_num_sig
        x = offset_data + offset_title + name_len*(r-1);
        title{r} = (d(x:(x+ name_len-1)))';
        title{r} = char(title{r});   
    end;  % looping through title
    
    numchan = num_a_d_chan;
    
    arecs.frm_arry_sz = frm_arry_sz;
    arecs.max_samp_rate = max_samp_rate;
    arecs.min_samp_rate = min_samp_rate;
    arecs.num_a_d_chan = num_a_d_chan;
    arecs.a_d_res = a_d_res;
    arecs.a_d_radix_comp = a_d_radix_comp;
    arecs.a_d_ov_gain = a_d_ov_gain;
    arecs.a_d_rate = a_d_rate(1:num_sig);
    arecs.store_rate = store_rate(1:num_sig);
    arecs.a_d_calib = a_d_calib(1:num_sig);
    arecs.shift = shift(1:num_sig);
    arecs.gain = gain(1:num_sig);
    arecs.a_d_delay = a_d_delay(1:num_sig);
    arecs.a_d_chan = a_d_chan(1:num_sig);
    arecs.frm_arry = frm_arry;
    arecs.gvname = {gvname{1:num_sig}};
    arecs.title = {title{1:num_sig}};
    arecs.numsig = num_sig;
    arecs.sig_in_frm = sig_in_frm;
    arecs.num_subframe = num_subframe;
    
else
    arecs.frm_arry_sz = [];
    arecs.num_a_d_chan = [];
    arecs.a_d_rate = [];
    arecs.store_rate = [];
    arecs.a_d_calib = [];
    arecs.shift = [];
    arecs.gain = [];
    arecs.a_d_delay = [];
    arecs.a_d_chan = [];
    arecs.frm_arry = [];
    arecs.gvname = [];
    arecs.title = [];
end;






