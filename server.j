const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// 数据库连接 (稍后在部署平台配置环境变量)
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/land3d';
mongoose.connect(mongoURI).then(() => console.log('MongoDB Connected'));

// 定义土地项目数据模型
const Project = mongoose.model('Project', {
    name: String,
    points: Array,
    area: Number
});

// API 路由：计算并保存面积
app.post('/api/calculate', async (req, res) => {
    const { name, points } = req.body;
    
    // 简易面积计算逻辑 (鞋带公式)
    let area = 0;
    for (let i = 0; i < points.length; i++) {
        let j = (i + 1) % points.length;
        area += points[i].x * points[j].z;
        area -= points[j].x * points[i].z;
    }
    area = Math.abs(area) / 2;

    const newProject = new Project({ name, points, area });
    await newProject.save();
    
    res.json({ success: true, area: area, id: newProject._id });
});

app.get('/', (req, res) => res.send('3D Land API is running...'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server on port ${PORT}`));
