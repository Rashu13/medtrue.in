import axios from 'axios';

const baseURL = 'http://localhost:5015/api';

async function verifyCategoryCreation() {
    try {
        console.log('Testing Category Creation...');
        const category = {
            name: `Test Category ${Date.now()}`,
            // details: 'Auto-generated test category'
        };

        const response = await axios.post(`${baseURL}/masters/categories`, category);

        if (response.status === 201 || response.status === 200) {
            console.log('✅ Category created successfully!');
            console.log('Response Data:', response.data);

            if (response.data.slug && response.data.uuid) {
                console.log('✅ Slug and UUID were auto-generated.');
            } else {
                console.log('⚠️ Warning: Slug or UUID missing in response (might be okay if not returned, checking GET next).');
            }
        } else {
            console.error(`❌ Unexpected status code: ${response.status}`);
        }

    } catch (error) {
        console.error('❌ Failed to create category:', error.response ? error.response.data : error.message);
        process.exit(1);
    }
}

verifyCategoryCreation();
