-- Migration Script for LLM Tables
-- Created for Sprint 1: Module Restauration
-- Date: 2025

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create enum types for LLM module
CREATE TYPE conversation_type AS ENUM ('voice', 'chat', 'shortcut');
CREATE TYPE message_role AS ENUM ('user', 'assistant', 'system');
CREATE TYPE message_type AS ENUM ('text', 'voice', 'order_intent');
CREATE TYPE data_extraction_type AS ENUM ('product', 'quantity', 'restaurant', 'address', 'time', 'price');

-- Table: llm_conversations
-- Stores conversation sessions with users
CREATE TABLE llm_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type conversation_type NOT NULL,
    title VARCHAR(255),
    context JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: llm_messages
-- Stores individual messages in conversations
CREATE TABLE llm_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES llm_conversations(id) ON DELETE CASCADE,
    role message_role NOT NULL,
    content TEXT NOT NULL,
    type message_type DEFAULT 'text',
    metadata JSONB DEFAULT '{}',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: voice_shortcuts
-- Stores user-defined voice shortcuts for quick ordering
CREATE TABLE voice_shortcuts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    phrase TEXT NOT NULL,
    order_data JSONB NOT NULL,
    is_active BOOLEAN DEFAULT true,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: extracted_data
-- Stores extracted entities from LLM processing
CREATE TABLE extracted_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id UUID NOT NULL REFERENCES llm_messages(id) ON DELETE CASCADE,
    type data_extraction_type NOT NULL,
    value TEXT NOT NULL,
    confidence DECIMAL(3, 2) CHECK (confidence >= 0 AND confidence <= 1),
    additional_info JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: user_contexts
-- Stores user preferences and context for personalized LLM responses
CREATE TABLE user_contexts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    language_preference VARCHAR(10) DEFAULT 'fr-FR',
    dietary_restrictions JSONB DEFAULT '[]',
    favorite_restaurants JSONB DEFAULT '[]',
    favorite_dishes JSONB DEFAULT '[]',
    average_order_value DECIMAL(10, 2),
    preferred_delivery_time VARCHAR(50),
    last_order_date DATE,
    total_orders INTEGER DEFAULT 0,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_llm_conversations_user_id ON llm_conversations(user_id);
CREATE INDEX idx_llm_conversations_type ON llm_conversations(type);
CREATE INDEX idx_llm_conversations_is_active ON llm_conversations(is_active);

CREATE INDEX idx_llm_messages_conversation_id ON llm_messages(conversation_id);
CREATE INDEX idx_llm_messages_timestamp ON llm_messages(timestamp DESC);
CREATE INDEX idx_llm_messages_role ON llm_messages(role);

CREATE INDEX idx_voice_shortcuts_user_id ON voice_shortcuts(user_id);
CREATE INDEX idx_voice_shortcuts_phrase ON voice_shortcuts(phrase);
CREATE INDEX idx_voice_shortcuts_is_active ON voice_shortcuts(is_active);

CREATE INDEX idx_extracted_data_message_id ON extracted_data(message_id);
CREATE INDEX idx_extracted_data_type ON extracted_data(type);

CREATE INDEX idx_user_contexts_user_id ON user_contexts(user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at columns
CREATE TRIGGER update_llm_conversations_updated_at 
    BEFORE UPDATE ON llm_conversations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_voice_shortcuts_updated_at 
    BEFORE UPDATE ON voice_shortcuts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_contexts_updated_at 
    BEFORE UPDATE ON user_contexts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to increment voice shortcut usage
CREATE OR REPLACE FUNCTION increment_shortcut_usage(shortcut_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE voice_shortcuts 
    SET usage_count = usage_count + 1,
        updated_at = NOW()
    WHERE id = shortcut_id;
END;
$$ LANGUAGE plpgsql;

-- Function to update user context after order
CREATE OR REPLACE FUNCTION update_user_context_after_order(
    p_user_id UUID,
    p_order_value DECIMAL,
    p_restaurant_id UUID,
    p_dishes JSONB
)
RETURNS void AS $$
BEGIN
    INSERT INTO user_contexts (user_id, average_order_value, total_orders, last_order_date)
    VALUES (p_user_id, p_order_value, 1, CURRENT_DATE)
    ON CONFLICT (user_id) DO UPDATE
    SET average_order_value = (
            (user_contexts.average_order_value * user_contexts.total_orders + p_order_value) / 
            (user_contexts.total_orders + 1)
        ),
        total_orders = user_contexts.total_orders + 1,
        last_order_date = CURRENT_DATE,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Row Level Security Policies
ALTER TABLE llm_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE llm_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_shortcuts ENABLE ROW LEVEL SECURITY;
ALTER TABLE extracted_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_contexts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own conversations
CREATE POLICY llm_conversations_policy ON llm_conversations
    FOR ALL USING (auth.uid() = user_id);

-- Policy: Users can only access messages from their conversations
CREATE POLICY llm_messages_policy ON llm_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM llm_conversations 
            WHERE llm_conversations.id = llm_messages.conversation_id 
            AND llm_conversations.user_id = auth.uid()
        )
    );

-- Policy: Users can only manage their own shortcuts
CREATE POLICY voice_shortcuts_policy ON voice_shortcuts
    FOR ALL USING (auth.uid() = user_id);

-- Policy: Users can only view extracted data from their messages
CREATE POLICY extracted_data_policy ON extracted_data
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM llm_messages 
            JOIN llm_conversations ON llm_messages.conversation_id = llm_conversations.id
            WHERE llm_messages.id = extracted_data.message_id 
            AND llm_conversations.user_id = auth.uid()
        )
    );

-- Policy: Users can only access their own context
CREATE POLICY user_contexts_policy ON user_contexts
    FOR ALL USING (auth.uid() = user_id);

-- Grant permissions to authenticated users
GRANT ALL ON llm_conversations TO authenticated;
GRANT ALL ON llm_messages TO authenticated;
GRANT ALL ON voice_shortcuts TO authenticated;
GRANT SELECT ON extracted_data TO authenticated;
GRANT ALL ON user_contexts TO authenticated;

-- Comment on tables
COMMENT ON TABLE llm_conversations IS 'Stores LLM conversation sessions with users';
COMMENT ON TABLE llm_messages IS 'Stores individual messages within conversations';
COMMENT ON TABLE voice_shortcuts IS 'User-defined voice shortcuts for quick ordering';
COMMENT ON TABLE extracted_data IS 'Extracted entities from LLM message processing';
COMMENT ON TABLE user_contexts IS 'User preferences and context for personalized responses';

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'LLM tables created successfully for Sprint 1';
END
$$;