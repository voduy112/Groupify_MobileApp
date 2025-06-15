<template>
  <div class="p-6">
    <h1 class="text-3xl font-bold text-gray-800 mb-6">⚠️ Reported Documents</h1>

    <div class="mb-6 max-w-md relative">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Search by title..."
        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring focus:ring-blue-200 pr-10 text-sm text-gray-700 placeholder-gray-400 shadow-sm"
      />
      <svg
        class="w-5 h-5 text-gray-400 absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        viewBox="0 0 24 24"
      >
        <circle cx="11" cy="11" r="7" />
        <line x1="21" y1="21" x2="16.65" y2="16.65" />
      </svg>
    </div>

    <div v-if="loading" class="text-gray-500 text-center">Loading...</div>
    <div v-else>
      <div v-if="error" class="text-red-500 text-center">{{ error }}</div>
      <div
        v-else-if="filteredDocuments.length === 0"
        class="text-gray-500 text-center"
      >
        No reported documents found.
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="doc in filteredDocuments"
          :key="doc._id"
          class="bg-white rounded-xl shadow p-4 flex flex-col"
        >
          <h2 class="text-lg font-bold text-gray-700">{{ doc.title }}</h2>
          <p class="text-sm text-gray-600 line-clamp-3">
            {{ doc.description || "No description" }}
          </p>

          <img
            v-if="doc.imgDocument"
            :src="doc.imgDocument"
            alt="Document Image"
            class="w-full h-40 object-cover rounded my-2"
          />

          <a
            v-if="doc.mainFile"
            :href="doc.mainFile"
            target="_blank"
            class="text-blue-500 hover:underline text-sm"
          >
            📄 Download File
          </a>

          <p class="mt-2 text-xs text-gray-500 text-left">
            Uploaded by: {{ doc.uploaderId || "Unknown" }}
          </p>
          <p class="text-xs text-gray-400 text-left">
            Created at: {{ formatDate(doc.createdAt) }}
          </p>
          <p class="mt-2 text-sm text-red-600 font-semibold text-left">
            Reports: {{ doc.reportCount }}
          </p>

          <div class="mt-4 flex gap-2">
            <button
              class="text-blue-600 hover:underline text-sm"
              @click="toggleReportDetails(doc)"
            >
              👁️
              {{
                reportDetailsVisible[doc._id] ? "Hide Details" : "View Details"
              }}
            </button>
            <button
              class="text-red-600 hover:underline text-sm"
              @click="confirmDelete(doc._id)"
            >
              🗑️ Delete
            </button>
            <button
              v-if="reportDetailsVisible[doc._id]"
              class="text-yellow-700 hover:underline text-sm"
              @click="cancelReport(doc._id)"
            >
              ❌ Cancel Report
            </button>
          </div>

          <div
            v-if="reportDetailsVisible[doc._id]"
            class="mt-2 p-2 bg-yellow-50 border border-yellow-300 rounded text-sm text-yellow-800"
          >
            <strong>Report Details:</strong>

            <div
              v-if="doc.reportReasons && doc.reportReasons.length"
              class="mt-2 space-y-2"
            >
              <div
                v-for="(report, index) in doc.reportReasons"
                :key="index"
                class="border-b border-yellow-200 pb-2"
              >
                <p>
                  - <strong>Lý do:</strong>
                  {{ report.reason || "Không có lý do" }}
                </p>
                <p class="ml-4 text-xs text-gray-600">
                  👤 Người báo cáo: {{ report.reporter }}
                </p>
                <p class="ml-4 text-xs text-gray-600">
                  📅 Ngày báo cáo: {{ formatDate(report.createdAt) }}
                </p>
              </div>
            </div>

            <div v-else class="mt-2 text-gray-600">
              Không có lý do chi tiết nào.
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";

const API_BASE = "http://localhost:5000/api/document";

export default {
  name: "ReportPage",
  data() {
    return {
      loading: true,
      documents: [],
      error: null,
      reportDetailsVisible: {},
      searchQuery: "",
    };
  },
  computed: {
    filteredDocuments() {
      const query = this.searchQuery.trim().toLowerCase();
      if (!query) return this.documents;
      return this.documents.filter((doc) =>
        doc.title?.toLowerCase().includes(query),
      );
    },
  },
  created() {
    this.fetchReportedDocuments();
  },
  methods: {
    async fetchReportedDocuments() {
      this.loading = true;
      this.error = null;
      try {
        const response = await axios.get(`${API_BASE}/reports`);
        if (Array.isArray(response.data)) {
          this.documents = response.data
            .filter((doc) => Number(doc.reportCount) > 0)
            .map((doc) => ({
              ...doc,
              reportReasons: (doc.reportReasons || []).map((r) => ({
                reason: r.reason,
                reporter: r.reporter?.name || r.reporter || "Không rõ",
                createdAt: r.createdAt || r.date,
              })),
            }));
        } else {
          this.documents = [];
          this.error = "Invalid data format from server.";
        }
      } catch (error) {
        console.error("Error fetching reported documents:", error);
        this.documents = [];
        this.error = "Failed to fetch documents.";
      } finally {
        this.loading = false;
      }
    },

    formatDate(dateStr) {
      if (!dateStr) return "Unknown";
      const d = new Date(dateStr);
      return isNaN(d.getTime()) ? "Invalid date" : d.toLocaleString("vi-VN");
    },

    toggleReportDetails(doc) {
      this.reportDetailsVisible = {
        ...this.reportDetailsVisible,
        [doc._id]: !this.reportDetailsVisible[doc._id],
      };
    },

    async confirmDelete(documentId) {
      const confirmed = window.confirm(
        "Bạn có chắc chắn muốn xóa tài liệu này không?",
      );
      if (!confirmed) return;

      try {
        await axios.delete(`${API_BASE}/${documentId}`);
        alert("Document deleted.");
        this.fetchReportedDocuments();
      } catch (error) {
        console.error("Delete failed:", error);
        alert("Failed to delete document.");
      }
    },

    async cancelReport(documentId) {
      const confirmed = window.confirm(
        "Bạn có chắc chắn muốn hủy tất cả báo cáo cho tài liệu này không?",
      );
      if (!confirmed) return;

      try {
        await axios.delete(`${API_BASE}/${documentId}/reports`);
        alert("Reports canceled.");
        this.fetchReportedDocuments();
        this.reportDetailsVisible[documentId] = false;
      } catch (error) {
        console.error("Cancel report failed:", error);
        alert("Failed to cancel reports.");
      }
    },
  },
};
</script>
