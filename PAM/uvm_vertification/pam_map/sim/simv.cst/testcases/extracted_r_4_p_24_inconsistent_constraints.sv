class c_4_24;
    integer fv_6 /*this._vcs_unit__2865831673_my_transaction_11_0__cons_calc_sum_1_array(keep)*/ = 51;

    constraint axi_cons_this    // (constraint_mode = ON) (/home/eda/feifan/vlc_plat/PAM/uvm_vertification/pam_map/sim/../sv_src/my_transaction.sv:18)
    {
       (0 == (fv_6 /*this._vcs_unit__2865831673_my_transaction_11_0__cons_calc_sum_1_array(keep)*/ % 2));
    }
endclass

program p_4_24;
    c_4_24 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "xzxzx1xzzxxzx00xxx10110110zxx00xzxxxzzzzzzxzzzxxxzzzxzzzzzxzzxzz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
