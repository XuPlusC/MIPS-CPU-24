/*
**  ���ߣ������
**  �޸ģ�����
**  ���ܣ����������
**  ��ַת���߼��հ��廪��ѧ����������pc��ַ�쳣���
*/
module pc(
	input wire 			clk,
	input wire 			resetn,
    
    input wire 			pc_en,
    input wire[31:0] 	branch_address, 	//���Է�֧ģ�����ת��ַ
    input wire 			is_branch, 			//��֧ģ����ת�ź�
    input wire 			is_exception, 		//�쳣ģ����ת�ź�
    input wire[31:0] 	exception_new_pc, 	//�����쳣ģ�����ת��ַ
	
	output reg[31:0] 	pc_reg,
    output 				illegal_pc_if
);
    
	parameter PC_INITIAL = 32'hbfc00000; //��һ��ָ�ʼִ�е�λ��

    reg[31:0] pc_next;
    
    //�Ƕ���ָ���ַ������2λ��Ϊ0�����쳣���ź�����ˮ�δ���MEM���쳣����ģ��
	assign illegal_pc_if = pc_reg[1] | pc_reg[0]; 

    always @(*) begin
        if (!resetn) begin
          pc_next <= PC_INITIAL;
        end
        else if(pc_en) begin //�����źž���PC����һ��ֵ���쳣��������ת����������ͨ����
            if(is_exception) begin
                pc_next <= exception_new_pc;
            end
            else if(is_branch) begin
                pc_next <= branch_address;
            end
            else begin
                pc_next <= pc_reg + 32'd4;
            end
        end
        else begin 
            pc_next <= pc_reg;
        end
    end

    always @(posedge clk) begin
        pc_reg <= pc_next;
    end
	
endmodule