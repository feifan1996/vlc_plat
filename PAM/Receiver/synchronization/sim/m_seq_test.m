clc;
clear all;
%%初始化

m_seq = [ -1     1    -1     1    -1    -1    -1     1    -1    -1     1     1     1 ...
          -1    -1    -1    -1    -1     1     1    -1    -1     1    -1     1     1 ...
          -1     1     1     1     1];
m_seq = [ -1    -1    -1    -1     1    -1     1    -1    -1     1     1    -1     1 ...
           1     1];
%m_seq = [m_seq_1 m_seq_1 m_seq_1];

m_length = length(m_seq);

num=1000;%总共1000个数
rand_seq_one_minus_one=rand(1,num);
rand_seq_one_minus_one(rand_seq_one_minus_one>0.5)=1;
rand_seq_one_minus_one(rand_seq_one_minus_one<=0.5)=-1;

rand_seq_one_minus_one(101:100+1*m_length) = m_seq;
% rand_seq_one_minus_one(101:100+4*m_length) = [m_seq m_seq m_seq m_seq];


%rand_seq_one_minus_one = 0.6*rand_seq_one_minus_one + 0.5*randn(1,num);
rand_seq_one_minus_one = rand_seq_one_minus_one + 0.5*randn(1,num);

M_d = zeros(num-m_length,1);

for d = 1:num-m_length
    
    for i = 0:m_length-1
        M_d(d) = M_d(d) + rand_seq_one_minus_one(d+i)*m_seq(i+1);
    end
%     sum_seq1 = sum(rand_seq_one_minus_one(d:d+m_length-1).^2);
%     sum_seq2 = sum(m_seq.^2);
%     M_d(d) = M_d(d)^2 /(sum_seq1*sum_seq2); 
end

plot(1:num-m_length,M_d);

