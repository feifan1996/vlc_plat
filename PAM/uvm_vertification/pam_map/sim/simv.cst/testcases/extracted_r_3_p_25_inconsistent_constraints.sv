class c_3_25;
    integer fv_6 /*this._vcs_unit__2865831673_my_transaction_11_0__cons_calc_sum_1_array(keep)*/ = 53;

    constraint axi_cons_this    // (constraint_mode = ON) (/home/eda/feifan/vlc_plat/PAM/uvm_vertification/pam_map/sim/../sv_src/my_transaction.sv:18)
    {
       (0 == (fv_6 /*this._vcs_unit__2865831673_my_transaction_11_0__cons_calc_sum_1_array(keep)*/ % 2));
    }
endclass

program p_3_25;
    c_3_25 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "x1x1z1xx0zx0xx1xz001zzz100z11x00zxxxzxzxzzzxzxxxzxzxzzxxxxzxzxzz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
