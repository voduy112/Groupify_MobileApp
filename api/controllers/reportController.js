const Report = require('../models/Report');

const reportController = {

    createReport: async (req, res) => {
        try {
            const { reporterId, reason, documentId, action } = req.body;

            if (!reporterId || !reason || !documentId) {
                return res.status(400).json({ error: 'Thiếu thông tin bắt buộc: reporterId, reason hoặc documentId' });
            }

            const newReport = new Report({
                reporterId,
                reason,
                documentId,
                action
            });

            const savedReport = await newReport.save();
            return res.status(201).json({ message: 'Tạo báo cáo thành công', report: savedReport });
        } catch (error) {
            console.error('Lỗi khi tạo báo cáo:', error);
            return res.status(500).json({ error: 'Không thể tạo báo cáo' });
        }
    },

    updateReport: async (req, res) => {
        try {
            const { id } = req.params;
            const { reason, action } = req.body;

            const report = await Report.findById(id);
            if (!report) {
                return res.status(404).json({ error: 'Không tìm thấy báo cáo' });
            }

            if (reason !== undefined) report.reason = reason;
            if (action !== undefined) report.action = action;

            const updatedReport = await report.save();
            return res.status(200).json({ message: 'Cập nhật báo cáo thành công', report: updatedReport });
        } catch (error) {
            console.error('Lỗi khi cập nhật báo cáo:', error);
            return res.status(500).json({ error: 'Không thể cập nhật báo cáo' });
        }
    },

    deleteReport: async (req, res) => {
        try {
            const { id } = req.params;
            const report = await Report.findById(id);
            if (!report) {
                return res.status(404).json({ error: 'Không tìm thấy báo cáo' });
            }

            await Report.findByIdAndDelete(id);
            return res.status(200).json({ message: 'Xóa báo cáo thành công' });
        } catch (error) {
            console.error('Lỗi khi xoá báo cáo:', error);
            return res.status(500).json({ error: 'Không thể xoá báo cáo' });
        }
    },

    getReportById: async (req, res) => {
        try {
            const { id } = req.params;
            const report = await Report.findById(id)
                .populate('reporterId', 'username email') // optional
                .populate('documentId', 'title');     // optional

            if (!report) {
                return res.status(404).json({ error: 'Không tìm thấy báo cáo' });
            }

            return res.status(200).json(report);
        } catch (error) {
            console.error('Lỗi khi lấy báo cáo theo ID:', error);
            return res.status(500).json({ error: 'Không thể lấy báo cáo' });
        }
    },

    getAllReports: async (req, res) => {
        try {
            const reports = await Report.find()
                .populate('reporterId', 'username email') // optional
                .populate('documentId', 'title');     // optional

            return res.status(200).json(reports);
        } catch (error) {
            console.error('Lỗi khi lấy tất cả báo cáo:', error);
            return res.status(500).json({ error: 'Không thể lấy danh sách báo cáo' });
        }
    },

    getReportsByDocumentId: async (req, res) => {
        try {
            const  documentId  = req.params.id;

            const reports = await Report.find({ documentId: documentId });
                // .populate('reporterId', 'username email') // optional
                // .populate('documentId', 'title');     // optional

            return res.status(200).json(reports);
        } catch (error) {
            console.error('Lỗi khi lấy báo cáo theo documentId:', error);
            return res.status(500).json({ error: 'Không thể lấy báo cáo theo documentId' });
        }
    },

    getReportByDocumentIdAndReporterId: async (req, res) => {
        try {
            const { documentId, reporterId } = req.params;
    
            if (!documentId || !reporterId) {
                return res.status(400).json({ error: 'Thiếu documentId hoặc reporterId' });
            }
    
            const report = await Report.findOne({ documentId, reporterId });
                // .populate('reporterId', 'username email')
                // .populate('documentId', 'title');
    
            if (!report) {
                return res.status(404).json({ error: 'Không tìm thấy báo cáo tương ứng' });
            }
    
            return res.status(200).json(report);
        } catch (error) {
            console.error('Lỗi khi lấy báo cáo theo documentId và reporterId:', error);
            return res.status(500).json({ error: 'Không thể lấy báo cáo' });
        }
    }
    
};

module.exports = reportController;
