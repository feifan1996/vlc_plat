class c_11_42;
    integer fv_6 /*this._vcs_unit__2865831673_my_transaction_11_0__cons_calc_sum_1_array(keep)*/ = 99;

    constraint axi_cons_this    // (constraint_mode = ON) (/home/eda/feifan/vlc_plat/PAM/uvm_vertification/pam_map/sim/../sv_src/my_transaction.sv:18)
    {
       (0 == (fv_6 /*this._vcs_unit__2865831673_my_transaction_11_0__cons_calc_sum_1_array(keep)*/ % 2));
    }
endclass

program p_11_42;
    c_11_42 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "zz1xz0000zzzzzx010x110x0zxxz11x0zzxxxzzzzxzzxxxxzzxzxzxzxzzxzxxx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
