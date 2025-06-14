import axios from "axios";

const API_URL = "http://localhost:5000/api";

export const login = async (email, password) => {
  try {
    const response = await axios.post(`${API_URL}/auth/login`, {
      email: email.trim(),
      password,
    });

    const user = response.data;

    if (user && user.accessToken) {
      localStorage.setItem("user", JSON.stringify(user));
      return { success: true, data: user };
    }

    return {
      success: false,
      message: "Đăng nhập thất bại. Không có accessToken.",
    };
  } catch (err) {
    console.error("Login error:", err.response?.data || err.message);
    return {
      success: false,
      message: err.response?.data?.message || "Lỗi máy chủ. Vui lòng thử lại.",
    };
  }
};

export const logout = () => {
  localStorage.removeItem("user");
};

export const getCurrentUser = () => {
  return JSON.parse(localStorage.getItem("user"));
};
