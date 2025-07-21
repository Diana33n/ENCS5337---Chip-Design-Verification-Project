//Design:

module spn_cu (
  input logic clk,
  input logic reset,
  input logic [1:0] opcode,
  input logic [15:0] in_data,
  input logic [31:0] key,
  output logic [15:0] out_data,
  output logic [1:0] valid
);


  function logic [3:0] sbox(input logic [3:0] in);
  case (in)
    4'b0000: sbox = 4'b1010; 
    4'b0001: sbox = 4'b0101; 
    4'b0010: sbox = 4'b1000; 
    4'b0011: sbox = 4'b0010; 
    4'b0100: sbox = 4'b0110; 
    4'b0101: sbox = 4'b1100; 
    4'b0110: sbox = 4'b0100; 
    4'b0111: sbox = 4'b0011; 
    4'b1000: sbox = 4'b0001; 
    4'b1001: sbox = 4'b0000; 
    4'b1010: sbox = 4'b1011; 
    4'b1011: sbox = 4'b1001; 
    4'b1100: sbox = 4'b1111; 
    4'b1101: sbox = 4'b1101; 
    4'b1110: sbox = 4'b0111; 
    4'b1111: sbox = 4'b1110; 
    default: sbox = 4'b0000;
  endcase
endfunction

  
 function logic [3:0] inv_sbox(input logic [3:0] in);
  case (in)
    4'b1010: inv_sbox = 4'b0000; 
    4'b0101: inv_sbox = 4'b0001; 
    4'b1000: inv_sbox = 4'b0010; 
    4'b0010: inv_sbox = 4'b0011; 
    4'b0110: inv_sbox = 4'b0100; 
    4'b1100: inv_sbox = 4'b0101; 
    4'b0100: inv_sbox = 4'b0110; 
    4'b0011: inv_sbox = 4'b0111;
    4'b0001: inv_sbox = 4'b1000; 
    4'b0000: inv_sbox = 4'b1001; 
    4'b1011: inv_sbox = 4'b1010;
    4'b1001: inv_sbox = 4'b1011; 
    4'b1111: inv_sbox = 4'b1100; 
    4'b1101: inv_sbox = 4'b1101; 
    4'b0111: inv_sbox = 4'b1110;
    4'b1110: inv_sbox = 4'b1111; 
    default: inv_sbox = 4'b0000;
  endcase
endfunction

 
//--------- Round Mixing --------- //  
  
	logic [15:0] round_key[2:0];

always_comb begin
  round_key[0] = {key[7:0], key[23:16]};
  round_key[1] = key[15:0];
  round_key[2] = {key[7:0], key[31:24]};
end

  
//--------- Sbox --------- //  
  
  function logic [15:0] substitute(input logic [15:0] in);
  substitute = {
    sbox(in[15:12]), sbox(in[11:8]),
    sbox(in[7:4]),   sbox(in[3:0])
  };
endfunction
  
  function logic [15:0] inv_substitute(input logic [15:0] in);
  inv_substitute = {
    inv_sbox(in[15:12]), inv_sbox(in[11:8]),
    inv_sbox(in[7:4]),   inv_sbox(in[3:0])
  };
endfunction


//--------- Pbox --------- //    
  
function logic [15:0] permute(input logic [15:0] in);
  permute = {in[7:0], in[15:8]}; // rotate left by 8 bits
endfunction


function logic [15:0] inv_permute(input logic [15:0] in);
  inv_permute = {in[7:0], in[15:8]}; // same as permute, since it's 8-bit rotate
endfunction

  
 // --------- ENCRYPT-------- //
  
 function logic [15:0] encrypt(input logic [15:0] data);
  logic [15:0] temp;
  temp = data ^ round_key[0];
  temp = substitute(temp);
  temp = permute(temp);

  temp = temp ^ round_key[1];
  temp = substitute(temp);
  temp = permute(temp);

  temp = temp ^ round_key[2];
  temp = substitute(temp); // No permutation in last round
  
  return temp;
endfunction

  //--------- Decrypt ---------//
  
function logic [15:0] decrypt(input logic [15:0] data);
  logic [15:0] temp;

  // Round 2 (no permutation in last encryption round)
  temp = inv_substitute(data);
  temp = temp ^ round_key[2];

  // Round 1
  temp = inv_permute(temp);
  temp = inv_substitute(temp);
  temp = temp ^ round_key[1];

  // Round 0
  temp = inv_permute(temp);
  temp = inv_substitute(temp);
  temp = temp ^ round_key[0];

  return temp;
endfunction

  
  //--------- LOGIC---------//
  
  logic [1:0]  prev_opcode;
  logic [15:0] prev_in_data;
  logic [31:0] prev_key;

always_ff @(posedge clk or posedge reset) begin
  if (reset) begin
    out_data     <= 16'h0000;
    valid        <= 2'b00;
    prev_opcode  <= 2'b00;
    prev_in_data <= 16'h0000;
    prev_key     <= 32'h00000000;
  end   else begin
    if ((opcode == 2'b01 || opcode == 2'b10) &&
        (opcode != prev_opcode || in_data != prev_in_data || key != prev_key)) begin

      prev_opcode  <= opcode;
      prev_in_data <= in_data;
      prev_key     <= key;

      case (opcode)
        2'b01: begin
          out_data <= encrypt(in_data);
          valid    <= 2'b01;
        end
        2'b10: begin
          out_data <= decrypt(in_data);
          valid    <= 2'b10;
        end
      endcase

    end else begin
      if (opcode != 2'b00 && opcode != 2'b01 && opcode != 2'b10)
        valid <= 2'b11;
      else
        valid <= 2'b00; 
    end
  end
end

endmodule