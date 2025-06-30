import axios from "axios";

const apiClient = axios.create({
  baseURL: "https://groupifymobileapp-production.up.railway.app",
  headers: {
    "Content-Type": "application/json",
  },
});

export default {
  getUsers() {
    return apiClient.get("/admin/users");
  },

  updateUser(userId, userData) {
    return apiClient.put(`/admin/users/${userId}`, userData);
  },

  updateUserRole(userId, role) {
    return apiClient.put(`/admin/users/${userId}`, { role });
  },

  deleteUser(userId) {
    return apiClient.delete(`/admin/users/${userId}`);
  },
};
