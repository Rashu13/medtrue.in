import Select from 'react-select';

const SearchableSelect = ({ label, name, options, loading, formik, ...props }) => {
    // Custom styles to match the existing Tailwind design
    const customStyles = {
        control: (provided, state) => ({
            ...provided,
            minHeight: '28px',
            height: '28px',
            fontSize: '14px',
            borderColor: state.isFocused ? '#0d9488' : '#9ca3af', // teal-600 : gray-400
            boxShadow: 'none',
            '&:hover': {
                borderColor: state.isFocused ? '#0d9488' : '#6b7280', // teal-600 : gray-500
            },
            borderRadius: '0', // Square borders as per legacy input
        }),
        valueContainer: (provided) => ({
            ...provided,
            padding: '0 8px',
            height: '26px',
        }),
        input: (provided) => ({
            ...provided,
            margin: '0',
            padding: '0',
        }),
        indicatorsContainer: (provided) => ({
            ...provided,
            height: '26px',
        }),
        menu: (provided) => ({
            ...provided,
            fontSize: '14px',
            zIndex: 9999,
        }),
        menuList: (provided) => ({
            ...provided,
            maxHeight: '150px', // Restrict height to prevent overflow
        }),
        option: (provided, state) => ({
            ...provided,
            backgroundColor: state.isSelected ? '#0f766e' : state.isFocused ? '#ccfbf1' : null, // teal-700 : teal-50
            color: state.isSelected ? 'white' : '#111827', // white : gray-900
            cursor: 'pointer',
        }),
    };

    // Transform options for react-select if they aren't already in { label, value } format
    // However, the facade likely returns raw data, so we might need to map them in the parent or here.
    // The previous implementation mapped them in the parent to <option>.
    // Here we'll expect the parent to pass an array of { label, value } objects.

    const handleChange = (option) => {
        formik.setFieldValue(name, option ? option.value : '');
    };

    const handleBlur = () => {
        formik.setFieldTouched(name, true);
    };

    // Find the current selected option object based on the formik value
    const selectedValue = options ? options.find(option => option.value === formik.values[name]) : null;

    return (
        <div className="grid grid-cols-[160px_1fr] items-center gap-2">
            <label className="text-gray-900 font-medium text-right pr-2 text-sm">{label}</label>
            <span className="hidden">:</span>
            <div className="flex gap-1">
                <div className="flex-grow">
                    <Select
                        name={name}
                        value={selectedValue}
                        onChange={handleChange}
                        onBlur={handleBlur}
                        options={options}
                        isLoading={loading}
                        placeholder={`-- Select ${label} --`}
                        styles={customStyles}
                        isClearable
                        {...props}
                    />
                </div>
                {props.onAdd && (
                    <button
                        type="button"
                        onClick={props.onAdd}
                        className="bg-teal-700 text-white px-2 hover:bg-teal-800 flex items-center justify-center h-[28px] w-[28px]"
                        title={`Add New ${label}`}
                    >
                        +
                    </button>
                )}
            </div>
            {formik.touched[name] && formik.errors[name] && (
                <p className="text-red-600 text-xs text-right col-start-2">{formik.errors[name]}</p>
            )}
        </div>
    );
};

export default SearchableSelect;
