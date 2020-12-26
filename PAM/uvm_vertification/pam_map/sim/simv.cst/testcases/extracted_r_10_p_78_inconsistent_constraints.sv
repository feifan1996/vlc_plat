class c_10_78;
    integer fv_6 /*this._vcs_unit__2865831673_my_transaction_11_0__cons_calc_sum_1_array(keep)*/ = 191;

    constraint axi_cons_this    // (constraint_mode = ON) (/home/eda/feifan/vlc_plat/PAM/uvm_vertification/pam_map/sim/../sv_src/my_transaction.sv:18)
    {
       (0 == (fv_6 /*this._vcs_unit__2865831673_my_transaction_11_0__cons_calc_sum_1_array(keep)*/ % 2));
    }
endclass

program p_10_78;
    c_10_78 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "x0x1xz0zxx011z01xzzx000zz01x110zxxzxxxzxzzxzxzxzxxxzzzzxzzxzxxxz";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
