#include<iostream>
#include<vector>
#include<sstream>
#include <algorithm>
#include <iomanip>
#include <random>
#include <fstream>
#include <string.h>

//format số

//// 16 bit
//#define BIT_WIDTH 16
//#define INTEGER_PART 3
//#define FRACTIONAL_PART 12

//32 bit
#define BIT_WIDTH 32
#define INTEGER_PART 7
#define FRACTIONAL_PART 24

//configuration for generating test
#define TEST_NUM 1000 // number of tests
#define ACCURACY 5 // Độ chính xác của kết quả được gen ra (số chữ số ở phần thập phân của kết quả được gen ra)
#define NOISE_SD 0.0005  //standard deviation of noise
#define DELTA 0.1 //Phần trăm sai số tối đa so với mẫu

//link to data files
#define link_to_H_complex "C:/Users/ROG STRIX/Desktop/projecy/memfile/H_complex.txt"
#define link_to_H_binary  "C:/Users/ROG STRIX/Desktop/projecy/memfile/H_binary.txt"
#define link_to_y_complex "C:/Users/ROG STRIX/Desktop/projecy/memfile/y_complex.txt"
#define link_to_y_binary  "C:/Users/ROG STRIX/Desktop/projecy/memfile/y_binary.txt"
#define link_to_n_complex "C:/Users/ROG STRIX/Desktop/projecy/memfile/n_complex.txt"
#define link_to_n_binary  "C:/Users/ROG STRIX/Desktop/projecy/memfile/n_binary.txt"
#define link_to_x_complex_software "C:/Users/ROG STRIX/Desktop/projecy/memfile/x_complex_software.txt"
#define link_to_x_complex_hardware "C:/Users/ROG STRIX/Desktop/projecy/memfile/x_complex_hardware.txt"
#define link_to_x_binary_hardware  "C:/Users/ROG STRIX/Desktop/projecy/memfile/x_binary_hardware.txt"

using namespace std;

//////////////////////////////////////////////////////////-Chuyển đổi format-////////////////////////////////////////////////////////
//Format số, 1 bit dấu, INTEGER_PART bit phần nguyên và FRACTIONAL_PART bit phần thập phân
string decimalToBinary(int num) {//Không xử lý số âm
	string res = "";
	int i = 0;
	int positive = abs(num);
	while (i < INTEGER_PART) {//Không xử lý số âm
		if (positive != 0) {
			res = (positive % 2 ? "1" : "0") + res;
			positive /= 2;
		}
		else res = "0" + res;
		i++;
	}
	return res;
}
int binaryToDecimal(string num) {
	int res = 0;
	int i = 0;
	while (i < INTEGER_PART) {
		res += int(num[INTEGER_PART - 1 - i] - 48) * pow(2, i);
		i++;
	}
	return res;
}
string encode(float num) {
	//chuyển từ số float thành binary
	string res = decimalToBinary(int(num));
	float phanThapPhan = abs(num - int(num));

	int i = 0;
	while (i < FRACTIONAL_PART) {
		phanThapPhan = phanThapPhan * 2.0;
		res += int(phanThapPhan) + 48;
		if (phanThapPhan >= 1) phanThapPhan -= 1;
		i++;
	}
	if (num >= 0) res = "0" + res;
	else res = "1" + res;
	return res;
}
float decode(string num) {
	//chuyển từ số binary 32 bit thành float
	float res = 0;
	res += float(binaryToDecimal(num.substr(1, INTEGER_PART)));//lấy 7 bit từ bit thứ 2(index 1)
	float res_temp = abs(res);
	string temp = num.substr(1 + INTEGER_PART, FRACTIONAL_PART); //Lấy 24 bit cuối
	int i = 0;
	while (i < FRACTIONAL_PART) {
		res_temp += float(temp[i] - 48) * pow(2, -(i + 1));
		i++;
	}
	return (num[0] - 48) ? -res_temp : res_temp;
}
string encode_matrix(float** A, int number_of_columm) {
	// Chuyển ma trận float sang dạng binary stream
	string res = "";
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < number_of_columm; j++) {
			res += encode(A[i][j]);
		}
	}
	return res;
}
float** decode_matrix(string A) {
	// Chuyển binary stream sang dạng ma trận float
	float** res = new float* [4];
	if (A.size() == 8 * BIT_WIDTH) {
		int k = 0;
		for (int i = 0; i < 4; i++) {
			res[i] = new float[2];
			for (int j = 0; j < 2; j++) {
				res[i][j] = decode(A.substr(k, BIT_WIDTH));
				k = k + BIT_WIDTH;
			}
		}
	}
	if (A.size() == 16 * BIT_WIDTH) {
		int k = 0;
		for (int i = 0; i < 4; i++) {
			res[i] = new float[4];
			for (int j = 0; j < 4; j++) {
				res[i][j] = decode(A.substr(k, BIT_WIDTH));
				k = k + BIT_WIDTH;
			}
		}
	}
	return res;
}
void show_matrix(float** A, int c) {
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < c; j++) {
			cout << A[i][j] << "      ";
		}
		cout << endl;
	}
}
void show_complex_matrix(float** A, int number_of_columm) {
	if (number_of_columm == 2) {
		if (A[1][0] >= 0) cout << A[0][0] << setw(2) << "+" << setw(4) << A[1][0] << "j";
		else cout << A[0][0] << setw(2) << "-" << setw(4) << abs(A[1][0]) << "j";
		cout << endl;
		if (A[3][0] >= 0) cout << setw(2) << A[2][0] << "+" << setw(4) << A[3][0] << "j";
		else cout << setw(2) << A[2][0] << "-" << setw(4) << abs(A[3][0]) << "j";
	}
	if (number_of_columm == 4) {
		if (A[1][0] >= 0) cout << A[0][0] << setw(2) << "+" << setw(4) << A[1][0] << "j";
		else cout << A[0][0] << setw(2) << "-" << setw(4) << abs(A[1][0]) << "j";
		if (A[1][2] >= 0) cout << setw(8) << A[0][2] << setw(2) << "+" << setw(4) << A[1][2] << "j";
		else cout << setw(8) << A[0][2] << setw(2) << "-" << setw(4) << abs(A[1][2]) << "j";
		cout << endl;
		if (A[3][0] >= 0) cout << A[2][0] << setw(2) << "+" << setw(4) << A[3][0] << "j";
		else cout << A[2][0] << setw(2) << "-" << setw(4) << abs(A[3][0]) << "j";
		if (A[3][2] >= 0) cout << setw(8) << A[2][2] << setw(2) << "+" << setw(4) << A[3][2] << "j";
		else cout << setw(8) << A[2][2] << setw(2) << "-" << setw(4) << abs(A[3][2]) << "j";
	}
}
float** getMatrix(string data) {
	// Chuyển từ dạng input string ma trận phức sang ma trận float
	data.erase(remove(data.begin(), data.end(), ' '), data.end());
	replace(data.begin(), data.end(), ';', ' ');
	replace(data.begin(), data.end(), ',', ' ');
	string temp = "";
	for (int i = 0; i < data.size(); i++) {
		if (data[i] >= 48 && data[i] <= 57 || data[i] == '.' || data[i] == '+' || data[i] == '-' || data[i] == ' ') temp += data[i];
		if (data[i] == 'j') {
			if (i == 0) {
				temp += 1;
				continue;
			}
			if (i > 0) {
				if (data[i - 1] >= 48 && data[i - 1] <= 57) continue;
				temp += "1";
			}
		}
	}
	stringstream stream(temp);
	vector<float> num;
	float n;
	while (stream >> n) num.push_back(n);
	float** res = new float* [4];
	if (num.size() == 4) {
		for (int i = 0; i < 4; i++) res[i] = new float[2];
		res[0][0] = num[0];
		res[0][1] = -num[1];
		res[1][0] = num[1];
		res[1][1] = num[0];
		res[2][0] = num[2];
		res[2][1] = -num[3];
		res[3][0] = num[3];
		res[3][1] = num[2];
	}
	if (num.size() == 8) {
		for (int i = 0; i < 4; i++) res[i] = new float[4];
		res[0][0] = num[0];
		res[0][1] = -num[1];
		res[0][2] = num[2];
		res[0][3] = -num[3];
		res[1][0] = num[1];
		res[1][1] = num[0];
		res[1][2] = num[3];
		res[1][3] = num[2];
		res[2][0] = num[4];
		res[2][1] = -num[5];
		res[2][2] = num[6];
		res[2][3] = -num[7];
		res[3][0] = num[5];
		res[3][1] = num[4];
		res[3][2] = num[7];
		res[3][3] = num[6];
	}
	return res;
}
void delete_matrix(float** A) {
	for (int i = 0; i < 4; i++)delete[]A[i];
	delete[]A;
}


/////////////////////////////////////////////////////////////-Computation-/////////////////////////////////////////////////////////////
float norm2(float* vector) {
	float temp = 0;
	for (int i = 0; i < 4; i++) temp += pow(vector[i], 2);
	return sqrt(temp);
}
float* proj(float* A, float* B) {
	float* res = new float[4];
	float temp = 0;
	for (int i = 0; i < 4; i++) temp += A[i] * B[i];
	for (int i = 0; i < 4; i++) res[i] = temp * B[i];
	return res;
}
float* matrix_subtract_4x1(float* A, float* B) {
	float* res = new float[4];
	for (int i = 0; i < 4; i++) res[i] = A[i] - B[i];
	return res;
}
float** matrix_subtract_4x2(float** A, float** B) {
	float** res = new float* [4];
	for (int i = 0; i < 4; i++) {
		res[i] = new float[2];
		for (int j = 0; j < 2; j++) {
			res[i][j] = A[i][j] - B[i][j];
		}
	}
	return res;
}
float** matrix_mul_4x4(float** A, float** B) {
	float** res;
	res = new float* [4];
	for (int i = 0; i < 4; i++) {
		res[i] = new float[4];
	}

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			res[i][j] = 0;
			for (int k = 0; k < 4; k++) {
				res[i][j] += A[i][k] * B[k][j];
			}
		}
	}
	return res;
}
float** matrix_mul_4x4_4x2(float** A, float** B) {
	float** res;
	res = new float* [4];
	for (int i = 0; i < 4; i++) res[i] = new float[2];
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 2; j++) {
			res[i][j] = 0;

			for (int k = 0; k < 4; k++) {
				res[i][j] += A[i][k] * B[k][j];
			}
		}
	}
	return res;
}
float** transpose(float** in) {
	float** out;
	out = new float* [4];
	for (int i = 0; i < 4; i++) out[i] = new float[4];
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			out[j][i] = in[i][j];
		}
	}
	return out;
}
float** Q_decomposition(float** H_matrix) {
	float** H_matrix_trans = transpose(H_matrix);
	float** Q_matrix;
	Q_matrix = new float* [4];
	for (int i = 0; i < 4; i++) {//duyệt từng cột
		Q_matrix[i] = new float[4];
		for (int j = 0; j < 4; j++) {//duyệt từng phần tử trong 1 cột
			if (i == 0) Q_matrix[i][j] = H_matrix_trans[i][j] / norm2(H_matrix_trans[i]); //cột 0
			if (i == 1) {
				float* proj_temp2_1 = proj(H_matrix_trans[i], Q_matrix[i - 1]);
				float* temp1 = matrix_subtract_4x1(H_matrix_trans[i], proj_temp2_1);
				Q_matrix[i][j] = temp1[j] / norm2(temp1);
				delete[]proj_temp2_1;
				delete[]temp1;
			}
			if (i == 2) {
				float* proj_temp3_1 = proj(H_matrix_trans[i], Q_matrix[i - 2]);
				float* proj_temp3_2 = proj(H_matrix_trans[i], Q_matrix[i - 1]);
				float* temp2 = matrix_subtract_4x1(H_matrix_trans[i], proj_temp3_1);
				float* temp3 = matrix_subtract_4x1(temp2, proj_temp3_2);
				Q_matrix[i][j] = temp3[j] / norm2(temp3);
				delete[]proj_temp3_1;
				delete[]proj_temp3_2;
				delete[]temp2;
				delete[]temp3;
			}
			if (i == 3) {
				float* proj_temp4_1 = proj(H_matrix_trans[i], Q_matrix[i - 3]);
				float* proj_temp4_2 = proj(H_matrix_trans[i], Q_matrix[i - 2]);
				float* proj_temp4_3 = proj(H_matrix_trans[i], Q_matrix[i - 1]);
				float* temp4 = matrix_subtract_4x1(H_matrix_trans[i], proj_temp4_1);
				float* temp5 = matrix_subtract_4x1(temp4, proj_temp4_2);
				float* temp6 = matrix_subtract_4x1(temp5, proj_temp4_3);
				Q_matrix[i][j] = temp6[j] / norm2(temp6);
				delete[]proj_temp4_1;
				delete[]proj_temp4_2;
				delete[]proj_temp4_3;
				delete[]temp4;
				delete[]temp5;
				delete[]temp6;
			}
		}
	}
	for (int i = 0; i < 4; i++) delete[]H_matrix_trans[i];
	delete[]H_matrix_trans;
	Q_matrix = transpose(Q_matrix);
	return Q_matrix;
}
float** R_decomposition(float** H_matrix) {
	float** R_matrix;
	float** Q_matrix = Q_decomposition(H_matrix);
	R_matrix = transpose(Q_matrix);
	R_matrix = matrix_mul_4x4(R_matrix, H_matrix);
	return R_matrix;
}
float** ZF_detector(float** y, float** n, float** H) {
	float** x = new float* [4];
	for (int i = 0; i < 4; i++) x[i] = new float[2];

	float** Q = Q_decomposition(H);
	float** R = R_decomposition(H);
	Q = transpose(Q);
	y = matrix_mul_4x4_4x2(Q, y);
	n = matrix_mul_4x4_4x2(Q, n);
	y = matrix_subtract_4x2(y, n);

	x[3][0] = y[3][0] / R[3][3];
	x[2][1] = -x[3][0];

	x[3][1] = y[3][1] / R[3][3];
	x[2][0] = x[3][1];

	x[1][0] = (y[1][0] - R[1][2] * x[2][0] - R[1][3] * x[3][0]) / R[1][1];
	x[0][1] = -x[1][0];

	x[1][1] = (y[1][1] - R[1][2] * x[2][1] - R[1][3] * x[3][1]) / R[1][1];
	x[0][0] = x[1][1];
	for (int i = 0; i < 4; i++) {
		delete[]Q[i];
		delete[]R[i];
	}
	delete[]Q;
	delete[]R;
	return x;

}


////////////////////////////////////////////////////////////-Process Input, Ouput-///////////////////////////////////////////////////////
double rand_float() {
	random_device                  rand_dev;
	mt19937                        generator(rand_dev());
	uniform_int_distribution<long> distr(0, 10 ^ ACCURACY);
	return 1.0 * distr(generator) / (10 ^ ACCURACY);
}
double rand_noise() {
	random_device                  rand_dev;
	mt19937                        generator(rand_dev());
	normal_distribution<double>    distr(0, NOISE_SD);
	return abs(distr(generator));
}
char rand_sign() {
	random_device                  rand_dev;
	mt19937                        generator(rand_dev());
	uniform_int_distribution<int>  distr(0, 1);
	return distr(generator) ? '+' : '-';
}
void generate_H() {
	// Generate Matrix H and store as complex data and binary data
	fstream output_cmp, output_bin;
	output_cmp.open(link_to_H_complex, ios::out);
	output_bin.open(link_to_H_binary, ios::out);
	for (int i = 0; i < TEST_NUM; i++) {
		string H_str = ((rand_sign() == '-') ? "-" : "") + to_string(rand_float()) + rand_sign() + to_string(rand_float()) + "j,"
			+ ((rand_sign() == '-') ? "-" : "") + to_string(rand_float()) + rand_sign() + to_string(rand_float()) + "j,"
			+ ((rand_sign() == '-') ? "-" : "") + to_string(rand_float()) + rand_sign() + to_string(rand_float()) + "j,"
			+ ((rand_sign() == '-') ? "-" : "") + to_string(rand_float()) + rand_sign() + to_string(rand_float()) + "j";
		if (H_str.find("+-") != string::npos) H_str.replace(H_str.find("+-"), 2, "-");
		if (H_str.find("-+") != string::npos) H_str.replace(H_str.find("-+"), 2, "-");
		if (H_str.find("++") != string::npos) H_str.replace(H_str.find("++"), 2, "+");
		if (H_str.find("--") != string::npos) H_str.replace(H_str.find("--"), 2, "+");
		output_cmp << H_str << endl;
		float** H = getMatrix(H_str);
		output_bin << encode_matrix(H, 4) << endl;
	}
	output_cmp.close();
	output_bin.close();
}
void generate_y() {
	// Generate Matrix y and store as complex data and binary data
	fstream output_cmp, output_bin;
	output_cmp.open(link_to_y_complex, ios::out);
	output_bin.open(link_to_y_binary, ios::out);
	for (int i = 0; i < TEST_NUM; i++) {
		string y_str = ((rand_sign() == '-') ? "-" : "") + to_string(rand_float()) + rand_sign() + to_string(rand_float()) + "j,"
			+ ((rand_sign() == '-') ? "-" : "") + to_string(rand_float()) + rand_sign() + to_string(rand_float()) + "j";
		if (y_str.find("+-") != string::npos) y_str.replace(y_str.find("+-"), 2, "-");
		if (y_str.find("-+") != string::npos) y_str.replace(y_str.find("-+"), 2, "-");
		if (y_str.find("++") != string::npos) y_str.replace(y_str.find("++"), 2, "+");
		if (y_str.find("--") != string::npos) y_str.replace(y_str.find("--"), 2, "+");
		output_cmp << y_str << endl;
		float** y = getMatrix(y_str);
		output_bin << encode_matrix(y, 2) << endl;
	}
	output_cmp.close();
	output_bin.close();
}
void generate_n() {
	// Generate Matrix n and store as complex data and binary data
	fstream output_cmp, output_bin;
	output_cmp.open(link_to_n_complex, ios::out);
	output_bin.open(link_to_n_binary, ios::out);
	for (int i = 0; i < TEST_NUM; i++) {
		string n_str = ((rand_sign() == '-') ? "-" : "") + to_string(rand_noise()) + rand_sign() + to_string(rand_noise()) + "j,"
			+ ((rand_sign() == '-') ? "-" : "") + to_string(rand_noise()) + rand_sign() + to_string(rand_noise()) + "j";
		if (n_str.find("+-") != string::npos) n_str.replace(n_str.find("+-"), 2, "-");
		if (n_str.find("-+") != string::npos) n_str.replace(n_str.find("-+"), 2, "-");
		if (n_str.find("++") != string::npos) n_str.replace(n_str.find("++"), 2, "+");
		if (n_str.find("--") != string::npos) n_str.replace(n_str.find("--"), 2, "+");
		output_cmp << n_str << endl;
		float** n = getMatrix(n_str);
		output_bin << encode_matrix(n, 2) << endl;
	}
	output_cmp.close();
	output_bin.close();
}
float*** get_H() {
	fstream input_H;
	input_H.open(link_to_H_complex, ios::in);
	float*** return_H = new float** [TEST_NUM];
	for (int i = 0; i < TEST_NUM; i++) {
		string H_str; getline(input_H, H_str);
		return_H[i] = getMatrix(H_str);
	}
	return return_H;
	input_H.close();
}
float*** get_y() {
	fstream input_y;
	input_y.open(link_to_y_complex, ios::in);
	float*** return_y = new float** [TEST_NUM];
	for (int i = 0; i < TEST_NUM; i++) {
		string y_str; getline(input_y, y_str);
		return_y[i] = getMatrix(y_str);
	}
	return return_y;
	input_y.close();
}
float*** get_n() {
	fstream input_n;
	input_n.open(link_to_n_complex, ios::in);
	float*** return_n = new float** [TEST_NUM];
	for (int i = 0; i < TEST_NUM; i++) {
		string n_str; getline(input_n, n_str);
		return_n[i] = getMatrix(n_str);
	}
	return return_n;
	input_n.close();
}
void ZF_DETECTOR(float*** y, float*** n, float*** H) {
	fstream output;
	output.open(link_to_x_complex_software, ios::out);
	for (int i = 0; i < TEST_NUM; i++) {
		float** x = ZF_detector(y[i], n[i], H[i]);
		string x_str = to_string(x[0][0]) + ((x[0][1] >= 0) ? "+" : "") + to_string(x[0][1]) + "j,"
			+ to_string(x[1][0]) + ((x[1][1] >= 0) ? "+" : "") + to_string(x[1][1]) + "j";
		if (x_str.find("+-") != string::npos) x_str.replace(x_str.find("+-"), 2, "-");
		if (x_str.find("-+") != string::npos) x_str.replace(x_str.find("-+"), 2, "-");
		if (x_str.find("++") != string::npos) x_str.replace(x_str.find("++"), 2, "+");
		if (x_str.find("--") != string::npos) x_str.replace(x_str.find("--"), 2, "+");
		output << x_str << endl;
	}
	output.close();
}
void convert_hardware_binary_to_complex() {
	fstream input_binary, output_complex;
	input_binary.open(link_to_x_binary_hardware, ios::in);
	output_complex.open(link_to_x_complex_hardware, ios::out);
	for (int i = 0; i < 3; i++) {
		string ignore_line;
		getline(input_binary, ignore_line);
	}
	for (int i = 0; i < TEST_NUM; i++) {
		string bin; getline(input_binary, bin);
		float** float_matrix = decode_matrix(bin);
		string complex_matrix = to_string(float_matrix[0][0]) + ((float_matrix[0][1] >= 0) ? "+" : "") + to_string(float_matrix[0][1]) + "j,"
			+ to_string(float_matrix[1][0]) + ((float_matrix[1][1] >= 0) ? "+" : "") + to_string(float_matrix[1][1]) + "j";
		if (complex_matrix.find("+-") != string::npos) complex_matrix.replace(complex_matrix.find("+-"), 2, "-");
		if (complex_matrix.find("-+") != string::npos) complex_matrix.replace(complex_matrix.find("-+"), 2, "-");
		if (complex_matrix.find("++") != string::npos) complex_matrix.replace(complex_matrix.find("++"), 2, "+");
		if (complex_matrix.find("--") != string::npos) complex_matrix.replace(complex_matrix.find("--"), 2, "+");

		output_complex << complex_matrix << endl;
	}
	input_binary.close(); output_complex.close();
}
void check_result() {
	fstream x_software, x_hardware, x_hard_cmp;
	x_software.open(link_to_x_complex_software, ios::in);
	x_hardware.open(link_to_x_complex_hardware, ios::in);
	int fail_count = 0;
	for (int i = 0; i < TEST_NUM; i++) {
		string x_soft_str; getline(x_software, x_soft_str);
		string x_hard_str; getline(x_hardware, x_hard_str);
		float** x_soft = getMatrix(x_soft_str);
		float** x_hard = getMatrix(x_hard_str);

		int fail = 0;
		for (int r = 0; r < 4; r++)
			for (int c = 0; c < 2; c++) {
				double delta = abs(x_soft[r][c] - x_hard[r][c]) / abs(x_soft[r][c]);
				if (delta > DELTA) fail = 1;
			}
		if (fail) {
			fail_count++;
			cout << "Test " << i + 1 << " failed!" << endl;
		}
		else cout << "Test " << i + 1 << " passed!" << endl;
	}
	cout << endl << endl << "Pass: " << (1 - 1.0 * fail_count / TEST_NUM) * 100 << "%" << endl;
	x_software.close(); x_hardware.close(); x_hard_cmp.close();
}


/////////////////////////////////////////////////////////////////-Main-/////////////////////////////////////////////////////////////////
int main() {
	//// Các hàm generate data
	//generate_H();
	//generate_y();
	//generate_n();

	//// Hàm ZF detector trên C++
	//ZF_DETECTOR(get_y(), get_n(), get_H());

	//// Sau khi chạy hardware
	//convert_hardware_binary_to_complex();

	//// So sánh kết quả hard và soft
	check_result();
	return 0;
}