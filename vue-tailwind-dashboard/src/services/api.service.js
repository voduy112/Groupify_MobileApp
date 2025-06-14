import axios from "axios";

const apiClient = axios.create({
  baseURL: "http://localhost:5000/api",
  headers: {
    "Content-Type": "application/json",
  },
});

export default {
  getUsers() {
    return apiClient.get("/admin/users");
  },

  updateUserRole(userId, role) {
    return apiClient.put(`/admin/users/${userId}`, { role });
  },

  deleteUser(userId) {
    return apiClient.delete(`/admin/users/${userId}`);
  },
};
